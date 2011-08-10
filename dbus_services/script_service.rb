require "dbus_services/dbus_service"
require "open4"

module DbusServices
  class ScriptService < DbusService
    FILE_INTERFACE = "org.opensuse.systemagents.script"
    dbus_interface(FILE_INTERFACE) do
      dbus_method :execute, "out result:a{sv}, in params:a{sv}" do |params,user|
        #TODO permissions check
        [execute(params)]
        #TODO exception rescue
      end
    end

    def self.service_name
      "org.opensuse.systemagents.script.#{filename}" #TODO check filename characters
    end

    def self.object_path
      "org/opensuse/systemagents/script/#{filename}" #TODO check filename characters
    end

    def self.filename(value=nil)
      instance_eval "def filename_for_service() \"#{value}\" end" if value #FIXME escape VALUE!!
      raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
      filename_for_service
    end

    def run command
      ret = {}
      status = Open4::popen4(command) do |pid,stdin,stdout,stderr|
        stdin.close
        ret["stdout"] = stdout.read.strip
        ret["stderr"] = stderr.read.strip
      end
      ret["exitstatus"] = status.exitstatus
      ret
    end
  end
end
