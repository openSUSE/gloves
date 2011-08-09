module DbusServices
  module PolkitChecker
    def check_permissions permission, options={}
      bus = DBus::SystemBus.instance
      rb_service = bus.service "org.freedesktop.PolicyKit1"
      instance = rb_service.object "/org/freedesktop/PolicyKit/Authority"
      instance.introspect #to get interfaces
      iface = instance["org.freedesktop.PolicyKit1.Authority"]
      interactive = !(options.delete "only_noninteractive_permission_check")
      flags = 0
      flags &= 1 if interactive
      #TODO get somehow correct subject
      result = iface.CheckAuthorization SUBJECT,permission, {}, flags,""
      #result structure http://hal.freedesktop.org/docs/polkit/eggdbus-interface-org.freedesktop.PolicyKit1.Authority.html#eggdbus-struct-AuthorizationResult
      raise "invalid permission" unless result[0] 
    end
  end
end
