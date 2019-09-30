# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Bridge
    module OpenTracing
      # A ScopeManager provides an API for interfacing with
      # OpenTelemetry Tracers and Spans as OpenTracing objects
      class ScopeManager
        def initialize(tracer)
          @tracer = tracer
        end

        # Activate the given span
        #
        # @param [Span] span An OpenTelemetry Span
        # @return [Span]
        def activate(span, finish_on_close: true)
          Span.new(@tracer.with_span(span))
        end

        # Get the active span as a OpenTracingBridge::Span
        #
        # @return [Span]
        def active
          Span.new(@tracer.current_span)
        end
      end
    end
  end
end
