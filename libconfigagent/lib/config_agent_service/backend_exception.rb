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

module ConfigAgentService
  # Represents exception thrown by intention from backend part like missing permission or wrong argument.
  # 
  # Contain features:
  # serialization via transportation layer
  # contain type from which can be automatic recovered on read
  # @see DbusClients::BackendException
  class BackendException < StandardError
    # Unique identifier of exception kind
    attr_reader :type

    # Exception defined by message and type. Usually child overload it.
    # @example Common usage in child
    #   class BigProblem < BackendException
    #     def initialize(msg = "Big problem happen")
    #       super(msg,"BIGPROBLEM")
    #     end
    #   end
    def initialize(msg,type)
      super(msg)
      @type = type
    end

    # Serializes exception to hash. Needed to by-pass transportation layer.
    def to_hash
      return {
        "error" => message,
        "backtrace" => backtrace,
        "error_type" => type
      }
    end
  end
end
