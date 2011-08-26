require "dbus_services/dbus_service"
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
