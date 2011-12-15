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

require "config_agent_service/backend_exception"

module ConfigAgentService
  class InsufficientPermission < BackendException
    attr_reader :permission
    def initialize(permission)
      super("Permission(#{permission} not granted.","ERR_PERMISSION")
      @permission = permission
    end

    def to_hash
      ret = super
      ret["permission"] = permission
      return ret
    end
  end
end
