# frozen_string_literal: true

module Mnemosyne
  module Probes
    class << self
      def register(*args)
        registry.register(*args)
      end

      def activate!
        registry.activate!
      end

      private

      def registry
        @registry ||= ::Mnemosyne::Registry.new
      end
    end
  end
end

module Kernel
  alias require_without_mn require

  def require(name)
    ret = require_without_mn(name)

    begin
      ::Mnemosyne::Probes.registry.required(name)
    rescue Exception # rubocop:disable RescueException, HandleExceptions
    end

    ret
  end
end
