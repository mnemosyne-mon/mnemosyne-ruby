# frozen_string_literal: true

require 'forwardable'

module Mnemosyne
  class Registry
    class Registration
      extend ::Forwardable

      attr_reader :class_name, :require_paths

      def initialize(class_name, require_paths, probe)
        @class_name = class_name
        @require_paths = Array(require_paths)
        @probe = probe
      end

      def installable?
        return true unless class_name

        Module.const_defined?(class_name)
      end

      delegate install: :@probe
    end

    def initialize
      @registrations = []
      @activated     = false
      @monitor       = Monitor.new
    end

    def activate!
      return if activated?

      @registrations.each(&method(:activate))

      @activated = true
    end

    def activated?
      @activated
    end

    def register(*args)
      @registrations << (registration = Registration.new(*args))

      activate(registration) if activated?
    end

    def required(path)
      return unless activated?
      return unless (set = monitor.delete(path))
      set.each(&method(:activate))
    end

    private

    attr_reader :monitor

    def activate(registration)
      if registration.installable?
        registration.install
      else
        monitor << registration
      end
    end

    class Monitor
      def initialize
        @requirements = Hash.new {|h, k| h[k] = Set.new }
      end

      def delete(path)
        @requirements.delete(path)
      end

      def <<(registration)
        registration.require_paths.each do |path|
          @requirements[path] << registration
        end
      end
    end
  end
end
