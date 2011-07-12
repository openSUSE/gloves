require "dbus_service"

class FileService < DbusService
  FILE_INTERFACE = "org.opensuse.systemagents.file.interface"
  dbus_interface(FILE_INTERFACE) do
    dbus_method :read, "out result:v{sv}, in params:v{sv}" do |result,params,user|
      #TODO permissions check
      [read(params)]
    end
      #TODO exception rescue
    dbus_method :write, "out result:v{sv}, in params:v{sv}" do |result,params,user|
      #TODO permissions check
      [write(params)]
      #TODO exception rescue
    end
  end

  def self.service_name
    "org.opensuse.systemagents.#{filename}.service" #TODO check filename characters
  end

  def self.object_path
    "org/opensuse/systemagents/#{filename}" #TODO check filename characters
  end

  def self.filename(value=nil)
    instance_eval "def filename_for_service \"#{value}\" end" if value #FIXME escape VALUE!!
    raise "File service doesn't define value its file name" unless respond_to? :filename_for_service
    filename_for_service
  end
end
