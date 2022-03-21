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
              'GET' => '*',
              'SET' => [0]
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
      end
    end

    register 'Redis::Client',
      'redis',
      Redis::Command::Probe.new
  end
end
