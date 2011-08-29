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
