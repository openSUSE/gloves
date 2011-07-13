require "rubygems"
require "dbus"

module DbusClients
  class FileClient
    FILE_INTERFACE = "org.opensuse.systemagents.file"
    def self.filename(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end

    def self.read (options)
      dbus_object.read(options).first #ruby dbus return array of return values
    end

    def self.write (options)
      dbus_object.write(options).first #ruby dbus return array of return values
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
