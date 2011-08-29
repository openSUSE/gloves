#--
# Config Agents Framework
#
# Copyright (C) 2011 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 or version 3 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

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
