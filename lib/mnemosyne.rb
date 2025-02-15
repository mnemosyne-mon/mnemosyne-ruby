# frozen_string_literal: true

require 'mnemosyne/version'

require 'logger'

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/notifications'

module Mnemosyne
  require 'mnemosyne/logging'

  require 'mnemosyne/global'
  extend Global

  require 'mnemosyne/clock'
  require 'mnemosyne/span'
  require 'mnemosyne/trace'

  require 'mnemosyne/configuration'
  require 'mnemosyne/client'
  require 'mnemosyne/instrumenter'

  require 'mnemosyne/registry'
  require 'mnemosyne/probe'
  require 'mnemosyne/probes'

  module Probes
    require 'mnemosyne/probes/mnemosyne/tracer'

    require 'mnemosyne/probes/acfs/request'
    require 'mnemosyne/probes/action_controller/process_action'
    require 'mnemosyne/probes/action_controller/renderers'
    require 'mnemosyne/probes/action_dispatch/show_exceptions'
    require 'mnemosyne/probes/action_view/render_partial'
    require 'mnemosyne/probes/action_view/render_template'
    require 'mnemosyne/probes/active_job/perform'
    require 'mnemosyne/probes/active_record/query'
    require 'mnemosyne/probes/active_record/instantiation'
    require 'mnemosyne/probes/faraday/base'
    require 'mnemosyne/probes/grape/endpoint_render'
    require 'mnemosyne/probes/grape/endpoint_run'
    require 'mnemosyne/probes/grape/endpoint_run_filters'
    require 'mnemosyne/probes/msgr/client'
    require 'mnemosyne/probes/msgr/consumer'
    require 'mnemosyne/probes/redis/command'
    require 'mnemosyne/probes/redis-client/command'
    require 'mnemosyne/probes/responder/respond'
    require 'mnemosyne/probes/restify/base'
    require 'mnemosyne/probes/sidekiq/client'
    require 'mnemosyne/probes/sidekiq/server'
    require 'mnemosyne/probes/view_component/render_component'
  end

  module Middleware
    require 'mnemosyne/middleware/rack'
  end

  module Support
    require 'mnemosyne/support/redis'
  end

  require 'mnemosyne/railtie' if defined?(Rails)
end
