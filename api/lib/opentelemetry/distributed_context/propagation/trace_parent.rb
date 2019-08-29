# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0
class OpenTelemetry::DistributedContext::Propagation::TraceParent
  Exception = Class.new(StandardError)
  InvalidFormatException = Class.new(Exception)
  InvalidVersonException = Class.new(Exception)
  InvalidTraceIDException = Class.new(Exception)
  InvalidSpanIDException = Class.new(Exception)

  TRACE_PARENT_HEADER = "traceparent"
  SUPPORTED_VERSION = 0
  MAX_VERSION = 254

  REGEXP = /^([a-f0-9]{2})-([a-f0-9]{32})-([a-f0-9]{16})-([a-f0-9]{2})(-.*)?$/.freeze
  private_constant :REGEXP

  attr_reader :version, :trace_id, :span_id, :flags

  def to_s
    sprintf("%02x-%032x-%016x-%s", version, trace_id, span_id, flags)
  end

  def initialize(trace_id: nil, span_id: nil, version: 0, flags: {})
    @trace_id = trace_id
    @span_id = span_id
    @version = version
    @flags = flags
  end

  def self.from_context(ctx)
    TraceParent.new(ctx.trace_id, ctx.span_id)
  end

  def parse(s)
    matches = REGEXP.match(s)

    raise InvalidFormatException if !matches || matches.length < 6

    @version = parse_version(matches[1])
    if version == SUPPORTED_VERSION && matches[5].length > 0
      raise InvalidFormatException
    end

    @trace_id = parse_trace_id(matches[2])
    @span_id = parse_span_id(matches[3])
    @flags = parse_flags(matches[4])
  end

  private

  def parse_version(s)
    v = parse_encoded_segment(s, 1)
    raise InvalidFormatException unless v
    raise InvalidVersonException if v > MAX_VERSION
    v
  end

  def parse_trace_id(s)
    id = parse_encoded_segment(s, 16)
    raise InvalidFormatException unless id
    raise InvalidTraceIDException if id == 0
    id
  end

  def parse_span_id(s)
    id = parse_encoded_segment(s, 8)
    raise InvalidFormatException unless id
    raise InvalidSpanIDException if id == 0
    id
  end

  def parse_flags(s)
    f = parse_encoded_segment(s, 1)
    raies InvalidFormatException unless f

    { recorded: f == 1 }
  end

  def parse_encoded_segment(src, len)
    return nil unless src.length == len
    [src].pack('H*')
  end
end
