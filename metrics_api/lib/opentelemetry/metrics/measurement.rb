# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Metrics
    # Measurement represents a single metric measurement with value and attributes.
    # It can optionally include exemplar data.
    class Measurement
      attr_reader :value, :attributes, :exemplar

      # Create a new Measurement
      #
      # @param [Numeric] value The measured value
      # @param [Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}] attributes
      #   The set of attributes associated with this measurement
      # @param [Exemplar, nil] exemplar Optional exemplar data for this measurement
      def initialize(value:, attributes: {}, exemplar: nil)
        @value = value
        @attributes = attributes
        @exemplar = exemplar
      end
    end
  end
end
