require "rubygems"
require "dbus"

class DbusService < DBus::Object
  def dispatch(msg)
    msg.params << msg.sender
    super(msg)
  end
end
