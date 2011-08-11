require "logger"

module DbusServices
  module Logger
    def log
      @log_instance ||= ::Logger.new("/var/log/systemagent-dbus_services.log") # no log rotation yet
    end

    # automatically include these methods also to class methods
    # when included in a class (auto extend the class)
    def self.included(base)
      base.extend(self)
    end
  end
end
