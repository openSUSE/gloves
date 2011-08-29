=begin
This file is part of LibConfigAgent.

LibConfigAgent is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
version 2.1 of the License.

LibConfigAgent is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibConfigAgent.  If not, see <http://www.gnu.org/licenses/>.
=end

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
      raise InsufficientPermission.new(permission) unless result[0][0]
    end
  end
end
