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
    require 'mnemosyne/probes/mnemosyne/tracer'

    require 'mnemosyne/probes/action_controller/process_action'
    require 'mnemosyne/probes/action_controller/renderers'
    require 'mnemosyne/probes/active_record'
    require 'mnemosyne/probes/responder'
  end

  module Middleware
    require 'mnemosyne/middleware/rack'
  end

  require 'mnemosyne/railtie' if defined?(Rails)
end
