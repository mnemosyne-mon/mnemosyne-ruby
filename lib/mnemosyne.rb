require 'mnemosyne/version'

require 'active_support'
require 'active_support/notifications'

module Mnemosyne
  require 'mnemosyne/global'
  extend Global

  require 'mnemosyne/clock'
  require 'mnemosyne/client'
  require 'mnemosyne/span'
  require 'mnemosyne/trace'
  require 'mnemosyne/probe'
  require 'mnemosyne/probes'

  module Probes
    require 'mnemosyne/probes/action_controller/process_action'
  end

  module Middleware
    require 'mnemosyne/middleware/rack'
  end

  require 'mnemosyne/railtie' if defined?(Rails)
end
