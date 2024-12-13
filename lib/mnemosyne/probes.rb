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

    module Loader
      module_function

      def require(name)
        super(name).tap do
          ::Mnemosyne::Probes.required(name)
        rescue Exception # rubocop:disable Lint/RescueException,Lint/SuppressedException
        end
      end
    end

    ::Kernel.prepend(Loader)
  end
end
