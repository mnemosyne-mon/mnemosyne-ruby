module Mnemosyne
  class Client

    def send(trace)
      puts "TODO: ::Mnemosyne::Client.send"
    end

    class << self
      def instance
        @instance ||= self.new
      end
    end
  end
end
