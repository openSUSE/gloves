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

require 'config_agent/augeas_wrapper'
require "augeas"

module ConfigAgent
  class Adjtime < ConfigAgent::AugeasWrapper

    FILE_PATH = "/etc/adjtime"
    
    def initialize( params = {})
      params[ :lens]    = "Adjtime.lns"
      params[ :path]    = FILE_PATH

      super( params);
    end  

    def read( params)
      return serialize( params)
    end

    def write( params)
      return deserialize( params)
    end

  end
end
