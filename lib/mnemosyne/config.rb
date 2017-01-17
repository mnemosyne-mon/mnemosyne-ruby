# frozen_string_literal: true
require 'socket'
require 'uri'
require 'cgi'

module Mnemosyne
  class Config
    attr_reader :application
    attr_reader :hostname
    attr_reader :amqp
    attr_reader :exchange
    attr_reader :logger
    attr_reader :server

    # rubocop:disable Metrics/AbcSize
    def initialize(config)
      @application = config.fetch('application').freeze
      @enabled     = config.fetch('enabled', true)
      @hostname    = config.fetch('hostname') { default_hostname }.freeze
      @exchange    = config.fetch('exchange', 'mnemosyne').freeze
      @logger      = config.fetch('logger') { Logger.new($stdout) }

      server       = config.fetch('server', 'amqp://localhost')
      @amqp        = AMQ::Settings.configure(server).freeze
      @server      = make_amqp_uri(@amqp).freeze

      raise 'Application must be configured' unless application.present?
      raise 'Hostname must be configured' unless hostname.present?
    end

    def enabled?
      @enabled
    end

    private

    def default_hostname
      Socket.gethostbyname(Socket.gethostname).first
    end

    def make_amqp_uri(amqp)
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
