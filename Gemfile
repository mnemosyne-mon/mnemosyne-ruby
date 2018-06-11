# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.6'
gem 'rubocop', '~> 0.56.0'
gem 'timecop', '~> 0.8.0'
gem 'appraisal'

group :development, :test do
  gem 'pry', require: false
  gem 'pry-byebug', require: false
end

group :test do
  gem 'msgr', require: false
  gem 'restify', require: false
  gem 'sidekiq', require: false
  gem 'webmock', require: false
end
