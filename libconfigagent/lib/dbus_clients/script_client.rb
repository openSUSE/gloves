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

require "dbus_clients/dbus_client"

module DbusClients
  class ScriptClient
    PERMISSION_PREFIX="org.opensuse.config_agent"
    # gets/sets agent id
    def self.agent_id(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end

    # call execute method on backend
    def self.execute (options)
      DbusClient.call(self.name,agent_id,"script","execute",options)
    end

    # get list of permission that given file can use
    # @return [Hash] returns hash in format method => permissions
    def self.polkit_permissions
      return {
          :execute => [PERMISSION_PREFIX,agent_id,"execute"].join(".")
        }
    end
  end
end
