require "rubygems"
require "dbus"

module DbusClients
  class ScriptClient
    SCRIPT_INTERFACE = "org.opensuse.systemagents.script"
    def self.filename(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end

    def self.execute (options)
      dbus_object.execute(options).first #ruby dbus return array of return values
    end

    def self.service_name
      "org.opensuse.systemagents.script.#{filename}" #TODO check filename characters
    end

    def self.object_path
      "/org/opensuse/systemagents/script/#{filename}" #TODO check filename characters
    end
  private
    def self.dbus_object
      bus = DBus::SystemBus.instance
      rb_service = bus.service service_name
      instance = rb_service.object object_path
      instance.introspect #to get interfaces
      iface = instance[SCRIPT_INTERFACE]
    end
  end
end
