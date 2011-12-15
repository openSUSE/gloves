#--
# Config Agents Framework
#
# Copyright (C) 2011 Novell, Inc.
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 or version 3 of the GNU Lesser General Public
# License as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require "config_agent_service/insufficient_permission"

module ConfigAgentService
  module PolicykitChecker
    def check_permissions sender,permission, options={}
      bus = DBus::SystemBus.instance
      pid = bus.proxy.GetConnectionUnixProcessID(sender)[0]
      rb_service = bus.service "org.freedesktop.PolicyKit1"
      instance = rb_service.object "/org/freedesktop/PolicyKit1/Authority"
      instance.introspect #to get interfaces
      iface = DBus::ProxyObjectInterface.new(instance,"org.freedesktop.PolicyKit1.Authority")
      iface.define_method("CheckAuthorization","out result:(bba{ss}), in param1:(sa{sv}), in param2:s, in param3:a{ss}, in param4:u, in param5:s")
      interactive = !(options.delete "only_noninteractive_permission_check")
      flags = 0
      flags &= 1 if interactive
      result = iface.CheckAuthorization ["system-bus-name",{"name"=> sender}],permission, {}, flags,""
      #result structure http://hal.freedesktop.org/docs/polkit/eggdbus-interface-org.freedesktop.PolicyKit1.Authority.html#eggdbus-struct-AuthorizationResult
      log.warn "User '#{bus.proxy.GetConnectionUnixUser(sender)[0]}' attemp to obtain #{permission} and failed" unless result[0][0]
      raise InsufficientPermission.new(permission) unless result[0][0]
    end
  end
end
