# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Metrics
    module Instrument
      # No-op implementation of Histogram.
      class Histogram
        # Updates the statistics with the specified amount.
        #
        # @param [numeric] amount The amount of the Measurement, which MUST be a non-negative numeric value.
        # @param [Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}] attributes
        #   Values must be non-nil and (array of) string, boolean or numeric type.
        #   Array values must not contain nil elements and all elements must be of
        #   the same basic type (string, numeric, boolean).
        # @param [Exemplar, nil] exemplar Optional exemplar data for this measurement
        def record(amount, attributes: {}, exemplar: nil); end

        # Records a measurement with the current span context as an exemplar
        #
        # @param [numeric] amount The amount of the Measurement, which MUST be a non-negative numeric value.
        # @param [Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}] attributes
        #   Values must be non-nil and (array of) string, boolean or numeric type.
        #   Array values must not contain nil elements and all elements must be of
        #   the same basic type (string, numeric, boolean).
        def record_with_exemplar(amount, attributes: {})
          # Get current span context
          span_context = OpenTelemetry::Trace.current_span.context
          return record(amount, attributes: attributes) unless span_context.valid?

          # Create exemplar with current span context
          exemplar = Exemplar.new(
            filtered_attributes: attributes,
            time_unix_nano: Time.now.to_i * 1_000_000_000,
            value: amount,
            span_id: span_context.span_id,
            trace_id: span_context.trace_id
          )

          record(amount, attributes: attributes, exemplar: exemplar)
        end
      end
    end
  end
end
