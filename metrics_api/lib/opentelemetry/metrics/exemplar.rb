# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Metrics
    # Exemplar represents a detailed sample data point that is attached to summary/aggregated metric data.
    # It provides additional context by linking metrics to traces and logs.
    #
    # @see https://opentelemetry.io/docs/specs/otel/metrics/data-model/#exemplars
    class Exemplar
      attr_reader :filtered_attributes, :time_unix_nano, :value, :span_id, :trace_id

      # Create a new Exemplar
      #
      # @param [Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}] filtered_attributes
      #   The set of attributes that were filtered out by the aggregator.
      # @param [Integer] time_unix_nano The time when the exemplar was recorded, in nanoseconds since Unix epoch
      # @param [Numeric] value The value of the exemplar point
      # @param [String] span_id The ID of the span that was active during the measurement (optional)
      # @param [String] trace_id The ID of the trace that was active during the measurement (optional)
      def initialize(filtered_attributes:, time_unix_nano:, value:, span_id: nil, trace_id: nil)
        @filtered_attributes = filtered_attributes
        @time_unix_nano = time_unix_nano
        @value = value
        @span_id = span_id
        @trace_id = trace_id
      end
    end
  end
end
