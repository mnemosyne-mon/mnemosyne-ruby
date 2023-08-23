# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Redis
      module Command
        class Probe < ::Mnemosyne::Probe
          def setup
            if Gem::Version.new(::Redis::VERSION) >= Gem::Version.new('5')
              ::RedisClient.register Instrumentation
            else
              ::Redis::Client.prepend ClientPatch
            end
          end

          module Instrumentation
            def call(command, redis_config)
              Instrumentation.instrument([command], client.server_url) { super }
            end

            def call_pipelined(commands, redis_config)
              Instrumentation.instrument(commands, client.server_url) { super }
            end

            class << self
              def instrument(commands, server_url)
                trace = ::Mnemosyne::Instrumenter.current_trace
                return yield unless trace

                span = ::Mnemosyne::Span.new 'db.query.redis',
                  meta: extract_span_meta(commands, server_url)

                span.start!

                begin
                  yield.tap do |retval|
                    span.meta[:error] = retval.message if retval.is_a?(::Redis::CommandError)

                    trace << span.finish!
                  end
                rescue StandardError => e
                  span.meta[:error] = e.message
                  trace << span.finish!
                  raise
                end
              end

              private

              def extract_span_meta(commands, server_url)
                {
                  server: server_url,

                  # Each command is an array, consisting of the command name and any
                  # arguments. We are only interested in the command name.
                  commands: extract_command_names(commands),

                  # If there are multiple commands, that must mean they were pipelined
                  # (i.e. run in parallel).
                  pipelined: commands.length > 1
                }
              end

              def extract_command_names(commands)
                commands.map do |c|
                  # Depending on how the methods on the Redis gem are called,
                  # there may be an additional level of nesting.
                  c = c[0] if c[0].is_a?(Array)

                  # For some commands, we also extract *some* of the arguments.
                  name, args = parse_name_and_args(c)

                  "#{name} #{args}".strip
                end.join("\n")
              end

              ##
              # A map of known commands to the arguments (identified by position)
              # that should be included verbatim in the metadata. Arguments not
              # listed here will be replaced by a "?" character.
              #
              # The value can be a list of safe argument indices, or "*" (all).
              #
              KNOWN_ARGUMENTS = {
                'BLPOP' => '*',
                'BRPOP' => '*',
                'EVALSHA' => [0, 1],
                'EXISTS' => '*',
                'EXPIRE' => '*',
                'GET' => '*',
                'HGET' => '*',
                'HGETALL' => '*',
                'HMGET' => '*',
                'HMSET' => [0, 1],
                'HSCAN' => '*',
                'INCRBY' => '*',
                'LLEN' => '*',
                'LPUSH' => [0],
                'LRANGE' => '*',
                'LREM' => [0, 1],
                'MGET' => '*',
                'MSET' => [0],
                'RPUSH' => [0],
                'RPOP' => '*',
                'SADD' => [0],
                'SCARD' => '*',
                'SCAN' => '*',
                'SCRIPT LOAD' => [],
                'SET' => [0],
                'SREM' => [0],
                'SSCAN' => '*',
                'UNLINK' => '*',
                'ZADD' => [0],
                'ZCARD' => '*',
                'ZINCRBY' => [0, 1],
                'ZRANGE' => '*',
                'ZRANGEBYSCORE' => '*',
                'ZREM' => [0],
                'ZREMRANGEBYSCORE' => '*',
                'ZREVRANGE' => '*',
                'ZSCAN' => '*'
              }.freeze

              def parse_name_and_args(command)
                command = command.dup

                # Symbols and lower-case names are allowed
                name = command.delete_at(0).to_s.upcase

                allowed = KNOWN_ARGUMENTS[name] || []
                args = case allowed
                         when '*' # All arguments considered safe
                           command
                         when Array # A list of allowed argument indices
                           command.each_with_index.map do |arg, index|
                             allowed.include?(index) ? arg : '?'
                           end
                         else # Unknown command - assume nothing is safe
                           Array.new(command.length, '?')
                       end.join(' ')

                [name, args]
              end
            end
          end

          module ClientPatch
            def process(commands)
              Instrumentation.instrument(commands, id) { super }
            end
          end
        end
      end
    end

    register 'Redis::Client',
      'redis',
      Redis::Command::Probe.new
  end
end
