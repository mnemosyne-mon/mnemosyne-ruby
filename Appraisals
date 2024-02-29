# frozen_string_literal: true

appraise 'core' do
  remove_gem 'rubocop'
end

appraise 'faraday-10' do
  remove_gem 'rubocop'

  group :test do
    gem 'faraday', '~> 1.0'
  end
end

appraise 'rails-71' do
  remove_gem 'rubocop'

  group :test do
    gem 'rails', '~> 7.1.0'
    gem 'sqlite3', '~> 1.4'
  end
end

appraise 'rails-70' do
  remove_gem 'rubocop'

  group :test do
    gem 'rails', '~> 7.0.0'
    gem 'sqlite3', '~> 1.4'
  end
end

appraise 'rails-61' do
  remove_gem 'rubocop'

  group :test do
    gem 'rails', '~> 6.1.0'
    gem 'sqlite3', '~> 1.4'
  end
end

appraise 'redis-40' do
  remove_gem 'rubocop'

  group :test do
    gem 'redis', '~> 4.0'
  end
end

appraise 'redis-50' do
  remove_gem 'rubocop'

  group :test do
    gem 'redis', '~> 5.0'
  end
end

appraise 'sidekiq-60' do
  remove_gem 'rubocop'

  group :test do
    gem 'sidekiq', '~> 6.0'
  end
end

appraise 'sidekiq-70' do
  remove_gem 'rubocop'

  group :test do
    gem 'sidekiq', '~> 7.0'
  end
end
