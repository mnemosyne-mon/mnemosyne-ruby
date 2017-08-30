# frozen_string_literal: true

module Mnemosyne
  class Probe
    include ::Mnemosyne::Logging

    def install
      setup

      self.class.subscriptions.each do |subscribe|
        ::ActiveSupport::Notifications.subscribe(subscribe) do |*args|
          trace = ::Mnemosyne::Instrumenter.current_trace
          next unless trace

          call(trace, *args)
        end
      end

      logger.debug(Mnemosyne) { "Installed probe #{self.class.name}" }
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
