# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.6'
gem 'timecop', '~> 0.9.1'

group :test do
  gem 'faraday'
  gem 'msgr'
  gem 'rails'
  gem 'redis'
  gem 'restify'
  gem 'sidekiq'
  gem 'sqlite3'
  gem 'webmock'
end

group :rubocop do
  gem 'rubocop', '~> 1.30.0'
end

group :development do
  gem 'appraisal'
  gem 'rake-release', '~> 1.3.0'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
end
