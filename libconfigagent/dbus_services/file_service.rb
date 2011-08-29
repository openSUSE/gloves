require "dbus_services/dbus_service"
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

require "dbus_services/backend_exception"

module DbusServices
  class FileService < DbusService
    FILE_INTERFACE = "org.opensuse.systemagents.file"
    dbus_interface(FILE_INTERFACE) do
      dbus_method :read, "out result:a{sv}, in params:a{sv}" do |params,sender|
        begin
          permission_name = "org.opensuse.systemagents.file.#{self.class.filename}.read"
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
          permission_name = "org.opensuse.systemagents.file.#{self.class.filename}.write"
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
      "org.opensuse.systemagents.file.#{filename}" #TODO check filename characters
    end

    def self.object_path
      "/org/opensuse/systemagents/file/#{filename}" #TODO check filename characters
    end

    def self.agent_id(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end
  end
end
