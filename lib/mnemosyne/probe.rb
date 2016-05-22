module Mnemosyne
  class Probe
    def install
      setup

      self.class.subscriptions.each do |subscribe|
        ::ActiveSupport::Notifications.subscribe(subscribe) do |*args|
          trace = ::Mnemosyne::Instrumenter.current_trace
          next unless trace

          call(trace, *args)
        end
      end

      ::Mnemosyne::Instrumenter.logger.debug { "Installed probe #{self.class.name}"}
    end

    def setup
      # noop
    end

    class << self
      def subscriptions
        @subscriptions ||= Set.new
      end

      def subscribe(name)
        subscriptions << name
      end
    end
  end
end
