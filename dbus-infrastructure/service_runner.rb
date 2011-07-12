require 'rubygems'
require 'dbus'

module ServiceRunner
  def self.run(service_class)
    # Choose the bus (could also be DBus::session_bus, which is not suitable for a system service)
    bus = DBus::system_bus
    # Define the service name
    service = bus.request_service(service_class.service_name)
    # Set the object path
    obj = service_class.new(service_class.object_path)
    # Export it!
    service.export(obj)

    # Now listen to incoming requests
    main = DBus::Main.new
    main << bus
    main.run
  end
end
