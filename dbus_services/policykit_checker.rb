require "dbus_services/insufficient_permission"

module DbusServices
  module PolicykitChecker
    def check_permissions sender,permission, options={}
      bus = DBus::SystemBus.instance
      uid = bus.proxy.GetConnectionUnixUser(sender)[0]
      return if uid == 0 #skip check of permission for root
      pid = bus.proxy.GetConnectionUnixProcessID(sender)[0]
      rb_service = bus.service "org.freedesktop.PolicyKit1"
      instance = rb_service.object "/org/freedesktop/PolicyKit1/Authority"
      instance.introspect #to get interfaces
      iface = instance["org.freedesktop.PolicyKit1.Authority"]
      interactive = !(options.delete "only_noninteractive_permission_check")
      flags = 0
      flags &= 1 if interactive
      result = iface.CheckAuthorization ["system-bus-name",{"name"=> sender}],permission, {}, flags,""
      #result structure http://hal.freedesktop.org/docs/polkit/eggdbus-interface-org.freedesktop.PolicyKit1.Authority.html#eggdbus-struct-AuthorizationResult
      log.info result.inspect
      raise InsufficientPermission.new(permission)# unless result[0][0]
    end
  end
end
