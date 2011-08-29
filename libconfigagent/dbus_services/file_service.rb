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

require "dbus_services/dbus_service"
require "dbus_services/backend_exception"

module DbusServices
  class FileService < DbusService
    FILE_INTERFACE = "org.opensuse.config_agent.file"
    dbus_interface(FILE_INTERFACE) do
      dbus_method :read, "out result:a{sv}, in params:a{sv}" do |params,sender|
        begin
          permission_name = "org.opensuse.config_agent.file.#{self.class.agent_id}.read"
          check_permissions sender, permission_name, params
          [read(params)]
        rescue BackendException => e
          [ e.to_hash ]
        rescue Exception => e
          [{ "error" => e.message, "backtrace" => e.backtrace.join("\n") }]
        end
      end
      dbus_method :write, "out result:a{sv}, in params:a{sv}" do |params,sender|
        begin
          permission_name = "org.opensuse.config_agent.file.#{self.class.agent_id}.write"
          check_permissions sender, permission_name, params
          [write(params)]
        rescue BackendException => e
          [ e.to_hash ]
        rescue Exception => e
          [{ "error" => e.message, "backtrace" => e.backtrace.join("\n") }]
        end
      end
    end

    def self.service_name
      "org.opensuse.config_agent.file.#{agent_id}" #TODO check filename characters
    end

    def self.object_path
      "/org/opensuse/config_agent/file/#{agent_id}" #TODO check filename characters
    end

    def self.agent_id(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end
  end
end
