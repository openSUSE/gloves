require "dbus_service"

module DbusServices
  class ScriptService < DbusService
    FILE_INTERFACE = "org.opensuse.systemagents.script.interface"
    dbus_interface(FILE_INTERFACE) do
      dbus_method :read, "out result:v{sv}, in params:v{sv}" do |result,params,user|
        #TODO permissions check
        [execute(params)]
        #TODO exception rescue
      end
    end

    def self.service_name
      "org.opensuse.systemagents.script.#{filename}.service" #TODO check filename characters
    end

    def self.object_path
      "org/opensuse/systemagents/script/#{filename}" #TODO check filename characters
    end

    def self.filename(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end
  end
end
