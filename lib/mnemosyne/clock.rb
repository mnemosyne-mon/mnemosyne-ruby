module Mnemosyne
  class Clock
    def tick
      now = Time.now
      now.to_i * 1_000_000_000 + now.usec * 1_000
    end

    class << self
      def default
        @default ||= Clock.new
      end

      def tick
        default.tick
      end
    end
  end
end
