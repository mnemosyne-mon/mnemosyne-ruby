# frozen_string_literal: true

require 'spec_helper'
require 'support/active_record'

RSpec.describe ::Mnemosyne::Probes::ActiveRecord::Query do
  before { Record.create name: 'test' }

  context 'adapter: sidekiq' do
    it 'creates a trace' do
      trace = with_trace do
        Record.where(name: 'test').take
      end

      expect(trace.span.size).to eq 2

      trace.span.first.tap do |span|
        expect(span.name).to eq 'db.query.active_record'
        expect(span.meta.keys).to match_array %i[sql binds]

        if ActiveRecord::VERSION::MAJOR < 5
          expect(span.meta).to match \
            sql: 'SELECT  "records".* FROM "records" WHERE "records"."name" = ? LIMIT 1',
            binds: ['test']
        else
          expect(span.meta).to match \
            sql: 'SELECT  "records".* FROM "records" WHERE "records"."name" = ? LIMIT ?',
            binds: ['test', 1]
        end
      end

      trace.span[1].tap do |span|
        expect(span.name).to eq 'db.instantiation.active_record'
        expect(span.meta.keys).to match_array %i[class_name count]
        expect(span.meta).to match \
          class_name: 'Record',
          count: 1
      end
    end
  end
end
