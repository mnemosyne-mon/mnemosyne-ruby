# frozen_string_literal: true

require 'spec_helper'
require 'support/redis'

RSpec.describe Mnemosyne::Probes::Redis::Command, probe: :redis do
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
    expect(span.meta[:commands]).to eq 'SET mykey ?'
    expect(span.meta[:server]).to match %r{^redis://127.0.0.1:16379(/0)?$}

    span = trace.span[1]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq 'GET mykey'
    expect(span.meta[:server]).to match %r{^redis://127.0.0.1:16379(/0)?$}
  end

  it 'creates just one span for pipelined (parallel) commands' do
    trace = with_trace do
      result = redis.pipelined do |r|
        r.set 'foo', 'bar'
        r.set 'baz', 'bam'
      end

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq "SET foo ?\nSET baz ?"
    expect(span.meta[:pipelined]).to eq true
    expect(span.meta[:server]).to match %r{^redis://127.0.0.1:16379(/0)?$}
  end

  it 'traces queued commands (also run in parallel when committing)' do
    if version_cmp(Redis::VERSION, :>=, '5')
      # Redis gem v5+ removed the deprecated #queue and #commit methods
      skip 'Not available in Redis 5+'
    end

    trace = with_trace do
      redis.queue 'SET', 'mykey', 'hello world'
      redis.queue 'SET', 'foo', 'bar'
      result = redis.commit

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq "SET mykey ?\nSET foo ?"
    expect(span.meta[:pipelined]).to eq true
    expect(span.meta[:server]).to match %r{^redis://127.0.0.1:16379(/0)?$}
  end

  it 'traces commands queued with array syntax' do
    if version_cmp(Redis::VERSION, :>=, '5')
      # Redis gem v5+ removed the deprecated #queue and #commit methods
      skip 'Not available in Redis 5+'
    end

    trace = with_trace do
      redis.queue %w[SET mykey hello]
      redis.queue %w[SET foo bar]
      result = redis.commit

      expect(result).to eq %w[OK OK]
    end

    expect(trace.span.length).to eq 1

    span = trace.span[0]
    expect(span.name).to eq 'db.query.redis'
    expect(span.meta[:commands]).to eq "SET mykey ?\nSET foo ?"
    expect(span.meta[:pipelined]).to eq true
    expect(span.meta[:server]).to match %r{^redis://127.0.0.1:16379(/0)?$}
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
    expect(span.meta[:commands]).to eq 'UNKNOWN_FUNCTION ?'
    expect(span.meta[:error]).to start_with 'ERR unknown command'
    expect(span.meta[:server]).to match %r{^redis://127.0.0.1:16379(/0)?$}
  end
end
