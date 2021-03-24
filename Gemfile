# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.6'
gem 'rubocop', '~> 1.12.0'
gem 'timecop', '~> 0.9.1'

group :test do
  gem 'faraday', ENV['FARADAY_VERSION'], require: false
  gem 'msgr',    ENV['MSGR_VERSION'],    require: false
  gem 'restify', ENV['RESTIFY_VERSION'], require: false
  gem 'sidekiq', ENV['SIDEKIQ_VERSION'], require: false

  gem 'rails', require: false
  gem 'sqlite3', require: false
  gem 'webmock', require: false
end

group :development do
  gem 'appraisal'
  gem 'rake-release', '~> 1.3.0'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
end
