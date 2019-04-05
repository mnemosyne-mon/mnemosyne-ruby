# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.6'
gem 'rubocop', '~> 0.67.1'
gem 'timecop', '~> 0.9.1'
gem 'appraisal'

gem 'rails', require: false

group :development, :test do
  gem 'pry', require: false
  gem 'pry-byebug', require: false
end

group :test do
  gem 'msgr', require: false
  gem 'restify', require: false
  gem 'sidekiq', require: false
  gem 'sqlite3', require: false
  gem 'webmock', require: false
end
