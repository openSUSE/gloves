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

require 'rubygems'
require 'dbus'

module DbusServices
  module ServiceRunner
    def self.run(service_class)
      # Choose the bus (could also be DBus::session_bus, which is not suitable for a system service)
      bus = DBus::system_bus
      # Define the service name
      service = bus.request_service(service_class.service_name)
      # Set the object path
      obj = service_class.new(service_class.object_path)
      # Export it!
      service.export(obj)

      # Now listen to incoming requests
      main = DBus::Main.new
      main << bus
      main.run
    end
  end
end
