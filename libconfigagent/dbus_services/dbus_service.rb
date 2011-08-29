=begin
This file is part of LibConfigAgent.

LibConfigAgent is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
version 2.1 of the License.

LibConfigAgent is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibConfigAgent.  If not, see <http://www.gnu.org/licenses/>.
=end

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
