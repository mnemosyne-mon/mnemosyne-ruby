# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.6'
gem 'rubocop', '~> 0.80.1'
gem 'timecop', '~> 0.9.1'

group :test do
  gem 'aws-sdk-core', '~> 3.0',          require: false
  gem 'aws-sdk-s3', '~> 1.0',            require: false
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
  gem 'rake-release', '~> 1.2.1'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
end
