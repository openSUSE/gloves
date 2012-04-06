#--
# Gloves Windowmanager Library
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

$LOAD_PATH << File.dirname(__FILE__)

require 'config_agent/windowmanager'

# module for windowmanager configuration
module Glove
  module Windowmanager

    def self.last_error
      return @error
    end

    @sysconfig_values = [
    	"DEFAULT_WM"
    ]

    # Read all settings relevant for windowmanager configuration (key:value map).
    def self.read(params)

      # read config files
      begin
        sysconfig_windowmanager	= ConfigAgent::Windowmanager.read({})
      rescue DbusClients::InsufficientPermission => e
        @error	= "User has no permission for action '#{e.permission}'."
        return nil
      end
return sysconfig_windowmanager
      ret	= {}

      sysconfig_windowmanager.each do |key, val|
      	ret[key.downcase]	= val if @sysconfig_values.include? key
      end
      ret["windowmanager"]	= sysconfig_windowmanager["WINDOWMANAGER"] || ""

      return ret
    end

    # Write Keyboard configuration
    def self.modify(config,params)

      ret		= {
	"success"	=> true
      }
      # TODO

      return ret
    rescue DbusClients::InsufficientPermission => e
      @error	= "User has no permission for action '#{e.permission}'."
      return nil
    end


  end
end
