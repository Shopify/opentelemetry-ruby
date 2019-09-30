# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Bridge
    module OpenTracing
      # Tracer provides a means of referencing
      # an OpenTelemetry::Tracer as a OpenTracing::Tracer
      class Tracer
        HTTP_TEXT_FORMAT = OpenTelemetry::DistributedContext::Propagation::HTTPTextFormat.new
        BINARY_FORMAT = OpenTelemetry::DistributedContext::Propagation::BinaryFormat.new
        attr_reader :scope_manager

        def initialize
          @scope_manager = ScopeManager.new OpenTelemetry.tracer
        end

        def active_span
          OpenTelemetry.tracer.current_span
        end

        def start_active_span(operation_name,
                              child_of: nil,
                              references: nil,
                              start_time: Time.now,
                              tags: nil,
                              ignore_active_scope: false,
                              finish_on_close: true)
          span = OpenTelemetry.tracer.start_span(operation_name,
                                                 with_parent: child_of,
                                                 attributes: tags,
                                                 links: references,
                                                 start_timestamp: start_time)
          OpenTelemetry.tracer.with_span(span)
        end

        def start_span(operation_name,
                       child_of: nil,
                       references: nil,
                       start_time: Time.now,
                       tags: nil,
                       ignore_active_scope: false)
          OpenTelemetry.tracer.start_span(operation_name,
                                          with_parent: child_of,
                                          attributes: tags,
                                          links: references,
                                          start_timestamp: start_time)
        end

        def inject(span_context, format, carrier, &block)
          case format
          when ::OpenTracing::FORMAT_TEXT_MAP, ::OpenTracing::FORMAT_RACK
            context = span_context.context
            HTTP_TEXT_FORMAT.inject(context, carrier, &block)
          when ::OpenTracing::FORMAT_BINARY
            # TODO: I don't think this is right
            yield carrier, TraceParent::TRACE_PARENT_HEADER, BINARY_FORMAT.to_bytes(span_context)
          else
            warn 'Unknown inject format'
          end
        end

        def extract(format, carrier, &block)
          case format
          when ::OpenTracing::FORMAT_TEXT_MAP, ::OpenTracing::FORMAT_RACK
            HTTP_TEXT_FORMAT.extract(carrier, &block)
          when ::OpenTracing::FORMAT_BINARY
            # TODO: I don't think this is right
            BINARY_FORMAT.from_bytes(carrier)
          else
            warn 'Unknown extract format'
          end
        end
      end
    end
  end
end
