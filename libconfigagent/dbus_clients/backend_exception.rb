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

require 'singleton'

module DbusClients
  class ExceptionRegister
    include Singleton
    attr_accessor :error_types_map

    def initialize
      @error_types_map = {}
    end

    def register_exception id, mod
      @error_types_map[id] = mod
    end
  end
  # @note how to add own exception:
  #   add your type to ExceptionRegister and ensure that your exception is loaded.
  #   As initialize parameter it gets hash with parameters from backend
  class BackendException < StandardError
    attr_reader :backend_backtrace
    def initialize(msg,backend_backtrace)
      super(msg)
      @backend_backtrace = backend_backtrace
    end

    def self.raise_from_hash params
      exc = ExceptionRegister.instance.error_types_map[params["error_type"]]
      if exc
        raise exc.new params
      else
        raise "Unknown exception type #{params["error_type"]}"
      end
    end
  end

  class InsufficientPermission < BackendException
    attr_reader :permission
    def initialize(params)
      super(params["error"],params["backtrace"])
      @permission = params["permission"]
    end
  end

  ExceptionRegister.instance.register_exception "ERR_PERMISSION", DbusClients::InsufficientPermission
end
