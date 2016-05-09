require 'forwardable'

module Mnemosyne
  module Probes
    class Registration
      extend ::Forwardable

      attr_reader :class_name, :require_paths

      def initialize(class_name, require_paths, probe)
        @class_name = class_name
        @require_paths = Array require_paths
        @probe = probe
      end

      def installable?
        return true unless class_name

        ::Mnemosyne::Probes.class_available? class_name
      end

      delegate install: :@probe
    end

    class << self
      def class_available?(class_name)
        Module.const_get(class_name).is_a? Class
      rescue NameError
        false
      end

      def register(*args)
        registration = Registration.new(*args)

        if registration.installable?
          registration.install
        else
          register_require_hook registration
        end
      end

      def require_hook(name)
        registration = require_hooks[name]
        return unless registration

        if registration.installable?
          registration.install

          unregister_require_hook registration
        end
      end

      def register_require_hook(registration)
        registration.require_paths.each do |path|
          require_hooks[path] = registration
        end
      end

      def unregister_require_hook(registration)
        registration.require_paths.each do |path|
          require_hooks.delete path
        end
      end

      private

      def require_hooks
        @require_hooks ||= {}
      end
    end
  end
end

module ::Kernel
  alias require_without_mn require

  def require(name)
    ret = require_without_mn(name)

    begin
      ::Mnemosyne::Probe.require_hook(name)
    rescue Exception
    end

    ret
  end
end
