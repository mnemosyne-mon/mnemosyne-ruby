# frozen_string_literal: true

module Mnemosyne
  module Global
    def trace(name, meta: {})
      ::ActiveSupport::Notifications.instrument 'trace.mnemosyne',
        name: name, meta: meta do

        yield
      end
    end

    def attach_error(err)
      return unless (trace = ::Mnemosyne::Instrumenter.current_trace)
      trace.attach_error(err)
    end
  end
end
