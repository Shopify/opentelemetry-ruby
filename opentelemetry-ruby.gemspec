# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opentelemetry/version'

Gem::Specification.new do |spec|
  spec.name          = 'opentelemetry-ruby'
  spec.version       = Opentelemetry::VERSION
  spec.authors       = ['Ian Quick', 'Francis Bogsyani']
  spec.email         = ['ian.quick@shopify.com']

  spec.summary       = 'OpenTelemetry client library'
  spec.homepage      = 'https://opentelemetry.com'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version = '> 2.3.0'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
