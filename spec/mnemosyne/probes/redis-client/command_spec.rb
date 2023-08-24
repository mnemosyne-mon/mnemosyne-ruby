# frozen_string_literal: true

require 'spec_helper'
require 'support/redis'

RSpec.describe Mnemosyne::Probes::RedisClient::Command, probe: :redis_client do
  let(:redis) { RedisClient.new host: '127.0.0.1', port: 16_379 }

  it 'still works without tracing' do
    redis.call('SET', 'mykey', 'hello world')
    result = redis.call('GET', 'mykey')

    expect(result).to eq 'hello world'
  end

  it 'creates a span for each command' do
    trace = with_trace do
      redis.with do |r|
        result1 = r.call('SET', 'mykey', 'hello world')
        result2 = r.call('GET', 'mykey')

        expect(result1).to eq 'OK'
        expect(result2).to eq 'hello world'
      end
    end

    expect(trace.span.length).to eq 3

    trace.span[0].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq 'HELLO ?'
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end

    trace.span[1].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq 'SET mykey ?'
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end

    trace.span[2].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq 'GET mykey'
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end
  end

  it 'creates just one span for pipelined (parallel) commands' do
    trace = with_trace do
      result = redis.pipelined do |r|
        r.call 'SET', 'foo', 'bar'
        r.call 'SET', 'baz', 'bam'
      end

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 2

    trace.span[0].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq 'HELLO ?'
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end

    trace.span[1].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq "SET foo ?\nSET baz ?"
      expect(span.meta[:pipelined]).to eq true
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end
  end

  it 'attaches errors to the span' do
    trace = with_trace do
      expect do
        redis.call 'UNKNOWN_FUNCTION', 'SOME_ARGUMENT'
      end.to raise_error(RedisClient::CommandError)
    end

    expect(trace.span.length).to eq 2

    trace.span[0].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq 'HELLO ?'
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end

    trace.span[1].tap do |span|
      expect(span.name).to eq 'db.query.redis'
      expect(span.meta[:commands]).to eq 'UNKNOWN_FUNCTION ?'
      expect(span.meta[:error]).to start_with 'ERR unknown command'
      expect(span.meta[:server]).to eq 'redis://127.0.0.1:16379/0'
    end
  end
end
