# frozen_string_literal: true

require 'spec_helper'
require 'rack'

RSpec.describe Mnemosyne::Middleware::Rack, probe: :rack do
  let(:app) { ->(_env) { response } }

  let(:rack) do
    app = self.app

    Rack::Builder.new do
      use Mnemosyne::Middleware::Rack
      run app
    end
  end

  let(:env) do
    {
      'REQUEST_METHOD' => 'HEAD',
      'REQUEST_PATH' => '/',
      'QUERY_STRING' => '?',
      'SERVER_PROTOCOL' => 'HTTP/1.1',
      'HTTP_ACCEPT' => '*/*',
      'HTTP_HOST' => 'localhost'
    }
  end

  let(:response) do
    [200, {'Content-Type' => 'text/plain'}, ['text']]
  end

  def consume(response)
    StringIO.new.tap do |out|
      response.last.tap do |body|
        body.to_enum(:each).inject(out) {|io, s| io << s.to_s }
      ensure
        body.close
      end
    end.string
  end

  it 'creates a trace' do
    trace = with_instrumentation do
      expect(consume(rack.call(env))).to eq 'text'
    end

    expect(trace.name).to eq 'app.web.request.rack'
  end

  it 'extracts metadata' do
    trace = with_instrumentation do
      expect(consume(rack.call(env))).to eq 'text'
    end

    expect(trace.name).to eq 'app.web.request.rack'
    expect(trace.meta).to eq \
      method: 'HEAD',
      path: '/',
      protocol: 'HTTP/1.1',
      query: '?',
      headers: {
        Accept: '*/*',
        Host: 'localhost',
        'User-Agent': nil
      },
      status: 200,
      content_type: 'text/plain'
  end

  context 'with a redirect' do
    let(:response) do
      [302, {'Location' => 'http://www.example.org'}, ['']]
    end

    it 'attaches the target location to the trace' do
      trace = with_instrumentation do
        consume rack.call(env)
      end

      expect(trace.name).to eq 'app.web.request.rack'
      expect(trace.meta).to include \
        location: 'http://www.example.org',
        status: 302
    end
  end

  context 'with application error' do
    let(:app) { ->(_env) { raise 'fail' } }

    it 'reports error in trace' do
      trace = with_instrumentation do
        expect { consume rack.call(env) }.to raise_error 'fail'
      end

      expect(trace.name).to eq 'app.web.request.rack'

      trace.errors.tap do |errors|
        expect(errors).to be_an Array
        expect(errors.size).to eq 1

        errors.first.tap do |error|
          expect(error.error).to be_a RuntimeError
          expect(error.error.message).to eq 'fail'
        end
      end
    end

    context 'while streaming response' do
      let(:app) { ->(_env) { [200, {}, body] } }
      let(:body) do
        Enumerator.new do |y|
          y.yield 'a'
          y.yield 'b'
          raise 'sfail'
        end
      end

      it 'reports error in trace' do
        trace = with_instrumentation do
          expect { consume rack.call(env) }.to raise_error 'sfail'
        end

        expect(trace.name).to eq 'app.web.request.rack'

        trace.errors.tap do |errors|
          expect(errors).to be_an Array
          expect(errors.size).to eq 1

          errors.first.tap do |error|
            expect(error.error).to be_a RuntimeError
            expect(error.error.message).to eq 'sfail'
          end
        end
      end
    end
  end

  context 'with exception on submit' do
    it 'does not abort response' do
      expect_any_instance_of(Mnemosyne::Trace).to receive(:submit).and_raise(Exception)

      expect do
        with_instrumentation do
          expect(consume(rack.call(env))).to eq 'text'
        end
      end.not_to raise_error
    end
  end
end
