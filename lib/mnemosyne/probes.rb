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

      def required(path)
        registry.required(path)
      end

      private

      def registry
        @registry ||= ::Mnemosyne::Registry.new
      end
    end
  end
end

module Kernel
  module_function

  alias require_without_mnemosyne require

  def require(name)
    require_without_mnemosyne(name).tap do
      ::Mnemosyne::Probes.required(name)
    rescue Exception # rubocop:disable Lint/RescueException,Lint/SuppressedException
    end
  end
end
