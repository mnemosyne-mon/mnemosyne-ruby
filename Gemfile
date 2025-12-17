# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 13.0'
gem 'rake-release', '~> 1.3.0'
gem 'rspec', '~> 3.6'
gem 'rubocop', '~> 1.82.0'

group :test do
  gem 'timecop', '~> 0.9.1'

  gem 'faraday'
  gem 'msgr'
  gem 'rails'
  gem 'redis'
  gem 'redis-client'
  gem 'restify'
  gem 'sidekiq'
  gem 'webmock'

  gem 'sqlite3', '~> 2.0'
end

group :development do
  gem 'appraisal', require: false
  gem 'debug', require: false
end
