require 'rails'

module Mnemosyne
  class Railtie < ::Rails::Railtie
    initializer 'mnemosyne.instrument' do |app|
      app.middleware.insert 0, ::Mnemosyne::Middleware::Rack
    end
  end
end
