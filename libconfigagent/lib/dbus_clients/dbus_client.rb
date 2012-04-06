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

require "dbus_clients/backend_exception"
require "dbus_clients/utils"

SERVICE_NAME = "org.opensuse.config_agent"
OBJECT_PATH = "/org/opensuse/config_agent"
INTERFACE = "org.opensuse.config_agent"

#Internal only module, do not use outside of config agent, unstable API
module DbusClients
  module DbusClient
    # call method in given agent name identified by id, with given type
    # @param [String] name bypass agent name for easier direct call
    # @param [String] id identifier of agent
    # @param [String] type of agent
    # @param [String] method to call
    # @param [Hash] options to pass to method
    # @return [Hash] with result from method
    # @raise [BackendException] if exception occur on backend
    def self.call name, id, type, method, options
      ret = if Process.euid == 0
          Utils.direct_call name, type, method.to_sym, options
        else
          #rubygems slow down ruby, so use only if necessary
          require "rubygems"
          require "dbus"
          bus = DBus::SystemBus.instance
          rb_service = bus.service SERVICE_NAME
          instance = rb_service.object OBJECT_PATH
          iface = DBus::ProxyObjectInterface.new(instance,INTERFACE)
          iface.define_method("call","out result:a{sv}, in id:s, in method:s, in data:a{sv}")
          iface.call("#{INTERFACE}.#{id}",method.to_s,options).first
      end
      if ret["error"]
        if ret["error_type"]
          BackendException.raise_from_hash ret
        else
          raise BackendException.new(ret["error"],ret["backtrace"])
        end
      end
      return ret
    end
  end
end

