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

    def initialize(config)
      @application = config.fetch('application').freeze
      @enabled     = config.fetch('enabled', true)
      @hostname    = config.fetch('hostname') { default_hostname }.freeze
      @exchange    = config.fetch('exchange', 'mnemosyne').freeze
      @logger      = config.fetch('logger') { Logger.new($stdout) }

      server       = config.fetch('server', 'amqp://localhost')
      @amqp        = AMQ::Settings.configure(server).freeze
      @server      = make_amqp_uri(@amqp).freeze

      if not application.present?
        raise RuntimeError, 'Application must be configured'
      end

      if not hostname.present?
        raise RuntimeError, 'Hostname must be configured'
      end
    end

    def enabled?
      !!@enabled
    end

    private

    def default_hostname
      Socket.gethostbyname(Socket.gethostname).first
    end

    def make_amqp_uri(amqp)
      uri = URI('')

      uri.scheme = amqp[:scheme]
      uri.user   = amqp[:user]
      uri.host   = amqp[:host]

      if amqp[:port] != AMQ::URI::AMQP_PORTS[uri.scheme]
        uri.port = amqp[:port]
      end

      if amqp[:vhost] != '/'
        uri.path = '/' + ::CGI.escape(amqp[:vhost])
      end

      uri
    end
  end
end
