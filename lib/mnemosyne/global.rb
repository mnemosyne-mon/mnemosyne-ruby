module Mnemosyne
  module Global
    KEY = :__mnemosyne_current_trace

    def current_trace
      Thread.current[KEY]
    end

    def current_trace=(trace)
      Thread.current[KEY] = trace
    end

    def trace(name, meta: {})
      ::ActiveSupport::Notifications.instrument 'trace.mnemosyne',
                                                name: name, meta: meta do
        yield
      end
    end
  end
end
