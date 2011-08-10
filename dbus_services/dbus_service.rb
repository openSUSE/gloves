require "rubygems"
require "dbus"
require "dbus_services/policykit_checker"

module DbusServices
  class DbusService < DBus::Object
    include PolicykitChecker
    def dispatch(msg)
      msg.params << msg.sender
      super(msg)
    end
  end
end
