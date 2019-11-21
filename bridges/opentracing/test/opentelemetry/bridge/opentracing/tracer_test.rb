# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Bridge::OpenTracing::Tracer do
  SpanContext = OpenTelemetry::Trace::SpanContext
  SpanContextBridge = OpenTelemetry::Bridge::OpenTracing::SpanContext
  let(:tracer_mock) { Minitest::Mock.new }
  let(:tracer_bridge) { OpenTelemetry::Bridge::OpenTracing::Tracer.new tracer_mock }
  describe '#active_span' do
    it 'gets the tracers active span' do
      tracer_mock.expect(:current_span, 'an_active_span')
      as = tracer_bridge.active_span
      as.must_equal 'an_active_span'
      tracer_mock.verify
    end
  end

  describe '#start_span' do
    it 'calls start span on the tracer' do
      args = ['name', { with_parent: 'parent', attributes: 'tag', links: 'refs', start_timestamp: 'now' }]
      tracer_mock.expect(:start_span, 'an_active_span', args)
      tracer_bridge.start_span('name', child_of: 'parent', references: 'refs', tags: 'tag', start_time: 'now')
      tracer_mock.verify
    end

    it 'calls with_span if a block is given, yielding the span and returning the blocks value' do
      args = ['name', { with_parent: 'parent', attributes: 'tag', links: 'refs', start_timestamp: 'now' }]
      tracer_mock.expect(:start_span, 'an_active_span', args)
      tracer_mock.expect(:with_span, 'block_value', ['an_active_span'])
      ret = tracer_bridge.start_span('name', child_of: 'parent', references: 'refs', tags: 'tag', start_time: 'now') do |span|
        span.must_equal 'an_active_span'
      end
      ret.must_equal 'block_value'
      tracer_mock.verify
    end

    it 'returns the span' do
      args = ['name', { with_parent: 'parent', attributes: 'tag', links: 'refs', start_timestamp: 'now' }]
      tracer_mock.expect(:start_span, 'an_active_span', args)
      span = tracer_bridge.start_span('name', child_of: 'parent', references: 'refs', tags: 'tag', start_time: 'now')
      tracer_mock.verify
      span.must_equal 'an_active_span'
    end
  end

  describe '#start_active_span' do
    it 'calls start span on the tracer and with_span to make active' do
      args = ['name', { with_parent: 'parent', attributes: 'tag', links: 'refs', start_timestamp: 'now' }]
      tracer_mock.expect(:start_span, 'an_active_span', args)
      tracer_bridge.start_active_span('name', child_of: 'parent', references: 'refs', tags: 'tag', start_time: 'now')
      tracer_mock.verify
    end

    it 'calls with_span if a block is given, yielding the scope and returning the blocks value' do
      args = ['name', { with_parent: 'parent', attributes: 'tag', links: 'refs', start_timestamp: 'now' }]
      tracer_mock.expect(:start_span, 'an_active_span', args)
      tracer_mock.expect(:with_span, 'block_value', ['an_active_span'])
      ret = tracer_bridge.start_active_span('name', child_of: 'parent', references: 'refs', tags: 'tag', start_time: 'now') do |scope|
        scope.span.must_equal 'an_active_span'
      end
      ret.must_equal 'block_value'
      tracer_mock.verify
    end

    it 'returns a scope' do
      args = ['name', { with_parent: 'parent', attributes: 'tag', links: 'refs', start_timestamp: 'now' }]
      tracer_mock.expect(:start_span, 'an_active_span', args)
      scope = tracer_bridge.start_active_span('name', child_of: 'parent', references: 'refs', tags: 'tag', start_time: 'now')
      tracer_mock.verify
      scope.span.must_equal 'an_active_span'
    end
  end

  describe '#inject' do
  end

  describe '#extract' do
  end
end
