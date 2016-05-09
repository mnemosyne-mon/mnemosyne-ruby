require 'socket'
require 'forwardable'

module Mnemosyne
  class Config
    extend Forwardable

    def initialize(config)
      @values = {
        enabled: true
      }

      config.each_pair do |key, value|
        @values[key.to_sym] = value
      end

      @values[:hostname] ||= Socket.gethostbyname(Socket.gethostname).first
    end

    def_delegators :@values, :[], :fetch, :key?

    REQUIRED = [
      :application,
      :hostname,
      :server
    ]

    def validate!
      REQUIRED.each do |required_key|
        next if self[required_key].present?

        raise RuntimeError.new "Configuration key missing: #{required_key}."
      end
    end

    def enabled?
      !!self[:enabled]
    end

    def logger
      @logger ||= @values[:logger] || Logger.new($stdout)
    end

    def application
      self[:application]
    end

    def hostname
      self[:hostname]
    end
  end
end
