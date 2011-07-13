require "rubygems"
require "dbus"

module DbusServices
  class DbusService < DBus::Object
    def dispatch(msg)
      msg.params << msg.sender
      super(msg)
    end
  end
end
