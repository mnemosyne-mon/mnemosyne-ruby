module Mnemosyne
  module Clock
    class << self
      def tick
        to_tick Time.now
      end

      def to_tick(time)
        time.to_i * 1_000_000_000 + time.nsec
      end
    end
  end
end
