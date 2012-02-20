#--
# YLib Global module
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

require "singleton"
require "dbus_clients/dbus_client"

module YLib
  class Configuration
    include Singleton
    attr_accessor :chroot

    def agent_parameters
      ret = {}
      ret["__chroot"] = chroot if chroot
      return ret
    end
  end
end

#reopen config_agents so all ylib implicitelly use agent parameters
module DbusClients
  module DbusClient
    class << self
      alias_method :ylib_conf_extended_call, :call
      def call name, id, type, method, options
        options = YLib::Configuration.instance.agent_parameters.merge options
        ylib_conf_extended_call name, id, type, method, options
      end
    end
  end
end
