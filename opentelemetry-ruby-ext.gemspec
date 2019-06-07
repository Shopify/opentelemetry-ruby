# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opentelemetry/version'

Gem::Specification.new do |spec|
  spec.name          = 'opentelemetry-ruby-ext'
  spec.version       = OpenTelemetry::VERSION
  spec.authors       = ['Ian Quick']
  spec.email         = ['ian.quick@shopify.com']

  spec.summary       = 'C extensions for opentelemetry client library'
  spec.homepage      = 'https://opentelemetry.com'
  spec.license       = 'Apache'

  spec.files         = Dir['ext/**/*.{h,c,cc}']
  spec.require_paths = ['lib']
  spec.extensions    = 'ext/opentelemetry-ruby-ext/extconf.rb'

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency 'opentelemetry', "= #{OpenTelemetry::VERSION}"
end
