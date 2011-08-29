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

require "dbus_services/backend_exception"

module DbusServices
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
