require "dbus_services/dbus_service"

module DbusServices
  class FileService < DbusService
    FILE_INTERFACE = "org.opensuse.systemagents.file"
    dbus_interface(FILE_INTERFACE) do
      dbus_method :read, "out result:a{sv}, in params:a{sv}" do |params,user|
        #TODO permissions check
        [read(params)]
        #TODO exception rescue
      end
      dbus_method :write, "out result:a{sv}, in params:a{sv}" do |params,user|
        #TODO permissions check
        [write(params)]
        #TODO exception rescue
      end
    end

    def self.service_name
      "org.opensuse.systemagents.file.#{filename}" #TODO check filename characters
    end

    def self.object_path
      "/org/opensuse/systemagents/file/#{filename}" #TODO check filename characters
    end

    def self.filename(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end
  end
end
