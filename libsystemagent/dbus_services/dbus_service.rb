require "rubygems"
require "dbus"
require "dbus_services/policykit_checker"
require "dbus_services/logger"

module DbusServices
  class DbusService < DBus::Object
    include PolicykitChecker
    include DbusServices::Logger
    def dispatch(msg)
      msg.params << msg.sender
      super(msg)
    end
  end
end
