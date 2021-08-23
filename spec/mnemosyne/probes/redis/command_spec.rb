# frozen_string_literal: true

require 'spec_helper'
require 'support/redis'

RSpec.describe ::Mnemosyne::Probes::Redis::Command, probe: :redis do
  let(:redis) { Redis.new host: '127.0.0.1', port: 16_379 }

  it 'still works without tracing' do
    redis.set('mykey', 'hello world')
    result = redis.get('mykey')

    expect(result).to eq 'hello world'
  end

  it 'creates a span for each command' do
    trace = with_trace do
      result1 = redis.set('mykey', 'hello world')
      result2 = redis.get('mykey')

      expect(result1).to eq 'OK'
      expect(result2).to eq 'hello world'
    end

    expect(trace.span.length).to eq 2

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'SET'

    span = trace.span[1]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'GET'
  end

  it 'creates just one span for pipelined (parallel) commands' do
    trace = with_trace do
      result = redis.pipelined do
        redis.set 'foo', 'bar'
        redis.set 'baz', 'bam'
      end

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'SET, SET'
    expect(span.meta[:pipelined]).to eq true
  end

  it 'traces queued commands (also run in parallel when committing)' do
    trace = with_trace do
      redis.queue 'SET', 'mykey', 'hello world'
      redis.queue 'SET', 'foo', 'bar'
      result = redis.commit

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'SET, SET'
    expect(span.meta[:pipelined]).to eq true
  end

  it 'traces commands queued with array syntax' do
    trace = with_trace do
      redis.queue %w[SET mykey hello]
      redis.queue %w[SET foo bar]
      result = redis.commit

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'SET, SET'
    expect(span.meta[:pipelined]).to eq true
  end

  it 'attaches errors to the span' do
    trace = with_trace do
      expect do
        redis.call 'UNKNOWN_FUNCTION', 'SOME_ARGUMENT'
      end.to raise_error(Redis::CommandError)
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'UNKNOWN_FUNCTION'
    expect(span.meta[:error]).to start_with 'ERR unknown command'
  end
end
