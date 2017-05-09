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
    attr_reader :logger
    attr_reader :server

    def initialize(config) # rubocop:disable AbcSize, MethodLength
      @platform    = config.fetch('platform', 'default').to_s.strip.freeze
      @application = config.fetch('application', nil).to_s.strip.freeze
      @enabled     = config.fetch('enabled', true)
      @exchange    = config.fetch('exchange', 'mnemosyne').to_s.freeze
      @logger      = config.fetch('logger') { Logger.new(STDOUT) }

      hostname  = config.fetch('hostname') { default_hostname }
      @hostname = hostname.to_s.strip.freeze

      server       = config.fetch('server', 'amqp://localhost')
      @amqp        = AMQ::Settings.configure(server).freeze
      @server      = make_amqp_uri(@amqp).to_s.freeze

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

    def make_amqp_uri(amqp) # rubocop:disable AbcSize
      uri = URI('')

      uri.scheme = amqp[:scheme]
      uri.user = amqp[:user]
      uri.host = amqp[:host]
      uri.port = amqp[:port] if amqp[:port] != AMQ::URI::AMQP_PORTS[uri.scheme]
      uri.path = '/' + ::CGI.escape(amqp[:vhost]) if amqp[:vhost] != '/'

      uri
    end
  end
end
