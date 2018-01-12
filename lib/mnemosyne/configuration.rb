# frozen_string_literal: true

require 'socket'
require 'uri'
require 'cgi'

module Mnemosyne
  class Configuration
    attr_reader :application
    attr_reader :hostname
    attr_reader :platform
    attr_reader :amqp
    attr_reader :exchange
    attr_reader :server

    def initialize(config) # rubocop:disable AbcSize
      @platform    = config.fetch('platform', 'default').to_s.strip.freeze
      @application = config.fetch('application', nil).to_s.strip.freeze
      @enabled     = config.fetch('enabled', true)
      @exchange    = config.fetch('exchange', 'mnemosyne').to_s.freeze

      hostname  = config.fetch('hostname') { default_hostname }
      @hostname = hostname.to_s.strip.freeze

      server       = config.fetch('server', 'amqp://localhost')
      @amqp        = AMQ::Settings.configure(server).freeze
      @server      = make_amqp_uri(@amqp).to_s.freeze

      raise ArgumentError.new 'Platform is required' if platform.blank?

      if @platform =~ /[^a-zA-Z0-9\-]/
        raise ArgumentError.new \
          'Platform may only contain alphanumeric characters'
      end

      unless @platform =~ /\A[a-zA-Z0-9]+(\-[a-zA-Z0-9]+)*\z/
        raise ArgumentError.new \
          'Platform must start and end with a alphanumeric characters'
      end

      raise ArgumentError.new('Application is required') if application.blank?
      raise ArgumentError.new('Hostname is required') if hostname.blank?
    end

    def enabled?
      @enabled
    end

    private

    def default_hostname
      Socket.gethostname
    end

    DEFAULT_PORTS = {
      'amqp' => 5672,
      'amqps' => 5671
    }

    def make_amqp_uri(amqp) # rubocop:disable AbcSize
      uri = URI('')

      uri.scheme = amqp[:scheme]
      uri.user = amqp[:user]
      uri.host = amqp[:host]
      uri.port = amqp[:port] if amqp[:port] != DEFAULT_PORTS[uri.scheme]
      uri.path = '/' + ::CGI.escape(amqp[:vhost]) if amqp[:vhost] != '/'

      uri
    end
  end
end
