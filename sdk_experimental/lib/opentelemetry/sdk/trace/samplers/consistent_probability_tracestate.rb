# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Trace
      module Samplers
        # @api private
        #
        # The ConsistentProbabilityTraceState module implements Tracestate parsing,
        # validation and manipulation for the consistent probability-based samplers.
        module ConsistentProbabilityTraceState
          MAX_LIST_LENGTH = 256 # Defined by https://www.w3.org/TR/trace-context/
          private_constant(:MAX_LIST_LENGTH)

          private

          # sanitized_tracestate returns an OpenTelemetry Tracestate object with the
          # tracestate sanitized according to the Context invariants defined in the
          # tracestate probability sampling spec.
          #
          # If r is nil after the sanitization, it is generated from the trace_id.
          #
          # This method assumes the parent span context is valid.
          #
          # @param trace_id [OpenTelemetry::Trace::TraceId] the trace id
          # @param span_context [OpenTelemetry::Trace::SpanContext] the parent span context
          # @return [OpenTelemetry::Trace::Tracestate] the sanitized tracestate
          def sanitized_tracestate(trace_id, span_context)
            sampled = span_context.trace_flags.sampled?
            tracestate = span_context.tracestate
            parse_ot_vendor_tag(tracestate) do |p, r, rest|
              if !r.nil? && r > 62
                p = r = nil
              elsif !p.nil? && p > 63
                p = nil
              elsif !p.nil? && !r.nil? && !invariant(p, r, sampled)
                p = nil
              elsif !r.nil?
                return tracestate
              end
              if r.nil?
                OpenTelemetry.logger.debug("ConsistentProbabilitySampler: potentially inconsistent trace detected - r: #{r.inspect}")
                r = generate_r(trace_id)
              end
              update_tracestate(tracestate, p, r, rest)
            end
          end

          # parse_ot_vendor_tag parses the 'ot' vendor tag of the tracestate.
          # It yields the parsed probability fields and the remaining tracestate.
          # It returns the result of the block.
          def parse_ot_vendor_tag(tracestate)
            return yield(nil, nil, nil) if tracestate.empty?

            ot = tracestate.value('ot')
            return yield(nil, nil, nil) if ot.nil? || ot.length > MAX_LIST_LENGTH # TODO: warn that we're rejecting the tracestate

            p = r = nil
            rest = nil
          
            i   = 0
            len = ot.length
          
            while i < len
              # Find the end of the current field (either `;` or end of string)
              j = ot.index(';', i) || len
          
              # Field boundaries are now [i, j)
              field_len = j - i
          
              if field_len >= 2 && ot.getbyte(i + 1) == 58 # 58 == ':'
                key_byte = ot.getbyte(i)
                val_start = i + 2
          
                # Fast-path only if key is 'p' or 'r'
                if (key_byte == 112 || key_byte == 114) # 'p' or 'r'
                  num = 0
                  k   = val_start
                  valid = false
                  while k < j
                    byte = ot.getbyte(k)
                    if byte >= 48 && byte <= 57 # '0'..'9'
                      num = num * 10 + (byte - 48)
                      valid = true
                      k += 1
                    else
                      valid = false
                      break
                    end
                  end
          
                  if valid
                    if key_byte == 112 # 'p'
                      p = num
                    else # 'r'
                      r = num
                    end
                  else
                    # Not a valid decimal value, treat as generic field
                    if rest
                      rest << ';'
                      rest << ot[i, field_len]
                    else
                      rest = ot[i, field_len].dup
                    end
                  end
                else
                  # Unknown key, copy to rest
                  if rest
                    rest << ';'
                    rest << ot[i, field_len]
                  else
                    rest = ot[i, field_len].dup
                  end
                end
              else
                # No colon or too short to be key:value, copy to rest
                if rest
                  rest << ';'
                  rest << ot[i, field_len]
                else
                  rest = ot[i, field_len].dup
                end
              end
          
              i = j + 1 # Move past the semicolon (or to len, which is fine)
            end
          
            # Align semantics with the original parse: return nil if no extra fields.
            rest = nil if rest&.empty?

            yield(p, r, rest)
          end

          def update_tracestate(tracestate, p, r, rest)
            if p.nil? && r.nil? && rest.nil?
              tracestate.delete('ot')
            elsif p.nil? && r.nil?
              tracestate.set_value('ot', rest)
            elsif p.nil? && rest.nil?
              tracestate.set_value('ot', "r:#{r}")
            elsif r.nil? && rest.nil?
              tracestate.set_value('ot', "p:#{p}")
            elsif p.nil?
              tracestate.set_value('ot', "r:#{r};#{rest}")
            elsif r.nil?
              tracestate.set_value('ot', "p:#{p};#{rest}")
            elsif rest.nil?
              tracestate.set_value('ot', "p:#{p};r:#{r}")
            else
              tracestate.set_value('ot', "p:#{p};r:#{r};#{rest}")
            end
          end

          def invariant(p, r, sampled)
            ((p <= r) == sampled) || (sampled && (p == 63))
          end

          def generate_r(trace_id)
            x = trace_id.unpack1('@8Q>') | 0x3
            64 - x.bit_length
          end
        end
      end
    end
  end
end
