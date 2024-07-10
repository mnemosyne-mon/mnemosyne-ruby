# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 13.0'
gem 'rubocop', '~> 1.65.0'

group :test do
  gem 'rspec', '~> 3.6'
  gem 'timecop', '~> 0.9.1'

  gem 'faraday'
  gem 'msgr'
  gem 'rails'
  gem 'redis'
  gem 'redis-client'
  gem 'restify'
  gem 'sidekiq'
  gem 'webmock'

  # Rails/ActiveRecord requires sqlite <2.0
  gem 'sqlite3', '~> 1.4'
end

group :development do
  gem 'appraisal'
  gem 'rake-release', '~> 1.3.0'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
end
