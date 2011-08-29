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

require "rubygems" #FIXME not nice to require rubygems, user of library should require it itself
require "dbus"
require "dbus_clients/backend_exception"

module DbusClients
  class FileClient
    FILE_INTERFACE = "org.opensuse.systemagents.file"
    def self.agent_id(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end

    def self.read (options)
      ret = dbus_object.read(options).first #ruby dbus return array of return values
      if ret["error"]
        if ret["error_type"]
          BackendException.raise_from_hash ret
        else
          raise BackendException.new(ret["error"],ret["backtrace"])
        end
      end
      return ret
    end

    def self.write (options)
      ret = dbus_object.write(options).first #ruby dbus return array of return values
      if ret["error"]
        if ret["error_type"]
          BackendException.raise_from_hash ret
        else
          raise BackendException.new(ret["error"],ret["backtrace"])
        end
      end
      return ret
    end

    def self.service_name
      "org.opensuse.systemagents.file.#{filename}" #TODO check filename characters
    end

    def self.object_path
      "/org/opensuse/systemagents/file/#{filename}" #TODO check filename characters
    end
  private
    def self.dbus_object
      bus = DBus::SystemBus.instance
      rb_service = bus.service service_name
      instance = rb_service.object object_path
      instance.introspect
      iface = instance[FILE_INTERFACE]
    end
  end
end
