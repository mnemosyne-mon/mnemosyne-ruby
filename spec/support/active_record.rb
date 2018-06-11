# frozen_string_literal: true

require 'rspec'
require 'sqlite3'
require 'active_record'

class Record < ActiveRecord::Base
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :records, force: true do |t|
    t.string :name
  end
end

RSpec.configure do |c|
  c.around do |example|
    ActiveRecord::Base.transaction(&example)
  end
end
