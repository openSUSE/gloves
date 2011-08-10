require "rubygems"
require "dbus"

module DbusServices
  class DbusService < DBus::Object
    include PolicykitChecker
    def dispatch(msg)
      msg.params << msg.sender
      super(msg)
    end
  end
end
