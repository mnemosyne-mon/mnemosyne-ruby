# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Redis
      module Command
        class Probe < ::Mnemosyne::Probe
          def setup
            ::Redis::Client.prepend ClientPatch
          end

          module ClientPatch
            def process(commands)
              trace = ::Mnemosyne::Instrumenter.current_trace
              return super unless trace

              span = ::Mnemosyne::Span.new 'db.query.redis',
                meta: extract_span_meta(commands)

              span.start!

              super.tap do |retval|
                span.meta[:error] = retval.message if retval.is_a?(::Redis::CommandError)

                trace << span.finish!
              end
            end

            private

            def extract_span_meta(commands)
              {
                server: id,

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

                # Symbols and lower-case names are allowed
                c[0].to_s.upcase
              end.join(', ')
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
