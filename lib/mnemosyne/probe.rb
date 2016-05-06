module Mnemosyne
  class Probe
    def install
      self.class.subscriptions.each do |subscribe|
        ::ActiveSupport::Notifications.subscribe(subscribe, &method(:call))
      end
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
