require 'mnemosyne/version'

module Mnemosyne
  require 'mnemosyne/clock'
  require 'mnemosyne/client'
  require 'mnemosyne/span'
  require 'mnemosyne/trace'

  module Middleware
    require 'mnemosyne/middleware/rack'
  end

  require 'mnemosyne/railtie' if defined?(Rails)
end
