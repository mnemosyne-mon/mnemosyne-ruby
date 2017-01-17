# frozen_string_literal: true

module Mnemosyne
  module Global
    def trace(name, meta: {})
      ::ActiveSupport::Notifications.instrument 'trace.mnemosyne',
        name: name, meta: meta do

        yield
      end
    end
  end
end
