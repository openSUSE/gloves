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
  # Module provide provide map between backend exception types and frontend variants
  # @example how to register new exception for given type
  #   class MyNewCoolException < DbusClients::BackendException
  #   end
  #   DbusClients::ExceptionRegister.instance.register_exception "ERR_MYCOOL", MyNewCoolException
  #
  #
  class ExceptionRegister
    include Singleton
    #map of types to classes
    attr_reader :error_types_map

    def initialize
      @error_types_map = {}
    end

    # add map from id to exception
    # @param [String] id of exception used in backend exception
    # @param [Class] class that represent exception on front end
    def register_exception id, mod
      @error_types_map[id] = mod
    end
  end

  # Represents base for Backend Exceptions
  class BackendException < StandardError
    # represents backtrace on backend side
    attr_reader :backend_backtrace

    # @param [String] msg user friendly message what is wrong
    # @param [Array[String]] backend_backtrace backtrace on backend side
    def initialize(msg,backend_backtrace)
      super(msg)
      @backend_backtrace = backend_backtrace
    end

    # Raised proped exception from given hash
    # @param [Hash] params from which exception is raised, passed to exception from ExceptionRegister
    # @option params [String] "error_type" type on backend
    # @raise [RuntimeError,BackendException] raise proper exception from mapping in ExceptionRegister. If no mapping found ( type not registered ) raise runtime error.
    def self.raise_from_hash params
      exc = ExceptionRegister.instance.error_types_map[params["error_type"]]
      if exc
        raise exc.new params
      else
        raise "Unknown exception type #{params["error_type"]}"
      end
    end
  end

  # Represent insufficient permission problem
  class InsufficientPermission < BackendException
    #permission that is missing
    attr_reader :permission
    def initialize(params)
      super(params["error"],params["backtrace"])
      @permission = params["permission"]
    end
  end

  ExceptionRegister.instance.register_exception "ERR_PERMISSION", DbusClients::InsufficientPermission
end
