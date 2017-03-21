# frozen_string_literal: true
require 'rails'

module Mnemosyne
  class Railtie < ::Rails::Railtie
    initializer 'mnemosyne.initialize' do |app|
      config = app.config_for('mnemosyne')

      config['application'] ||= app.class.name.underscore.titleize

      config['logger']  ||= Rails.logger
      config['enabled'] ||= config.key?('server')

      config = ::Mnemosyne::Config.new(config)

      if config.enabled?
        ::Mnemosyne::Instrumenter.start!(config)

        app.middleware.insert 0, ::Mnemosyne::Middleware::Rack
      else
        config.logger.warn '[MNEMOSYNE] Instrumenter not enabled.'
      end
    end
  end
end
