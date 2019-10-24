# frozen_string_literal: true

require 'rails'

module Mnemosyne
  class Railtie < ::Rails::Railtie
    initializer 'mnemosyne.initialize' do |app|
      config = app.config_for('mnemosyne').stringify_keys

      ::Mnemosyne::Logging.logger = Rails.logger

      config['application'] ||= app.class.name.underscore.titleize

      # If server is configured mnemosyne should be enabled by default
      config['enabled'] = config.key?('server') unless config.key?('enabled')

      config = ::Mnemosyne::Configuration.new(config)

      if config.enabled?
        ::Mnemosyne::Instrumenter.start!(config)

        app.middleware.insert 0, ::Mnemosyne::Middleware::Rack
      else
        Rails.logger.warn(Mnemosyne) { 'Instrumentation disabled' }
      end
    end
  end
end
