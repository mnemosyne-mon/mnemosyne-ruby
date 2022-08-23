# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mnemosyne/version'

Gem::Specification.new do |spec|
  spec.name          = 'mnemosyne-ruby'
  spec.version       = Mnemosyne::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = ['jgraichen@altimos.de']

  spec.summary       = 'Ruby/Rails client for Mnemosyne APM'
  spec.homepage      = 'http://github.com/jgraichen/mnemosyne-ruby'
  spec.license       = 'MIT'

  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.7'
  spec.add_runtime_dependency 'activesupport', '>= 4'
  spec.add_runtime_dependency 'bunny'

  spec.add_development_dependency 'bundler'
end
