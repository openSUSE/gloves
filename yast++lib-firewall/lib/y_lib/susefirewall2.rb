#--
# YaST++ SuSEfirewall2 Library
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

require 'config_agent/susefirewall2'

# module for SuSEfirewall2 configuration
module YLib
  module Susefirewall2

    DEFAULT_RET = { "success" => true }
    DEFAULT_ZONE = "EXT"
    DEFAULT_PROTOCOL = "TCP"

    def self.last_error
      return @error
    end

    # Read all settings relevant for SuSEfirewall2 configuration (key:value map)
    def self.read(params)
      begin
        sysconfig_susefirewall2 = ConfigAgent::Susefirewall2.read({})
      rescue DbusClients::InsufficientPermission => e
        @error = "User has no permission for action '#{e.permission}'."
        return nil
      end

      ret = {}

      sysconfig_susefirewall2.each do |key, val|
        ret[key.downcase] = val
      end

      return ret
    end

    # Write SuSEfirewall2 configuration
    def self.modify(config, params)
      ret = DEFAULT_RET.dup

      return ret if  params.nil? || params.empty?

      sysconfig_params = {}

      params.each do |key, val|
        sysconfig_params[key.upcase] = val
      end

      ret = ConfigAgent::Susefirewall2.write(sysconfig_params)

      return ret
    rescue DbusClients::InsufficientPermission => e
      @error = "User has no permission for action '#{e.permission}'."
      return nil
    end

    #
    # add({}, {"kind" => "service", "service" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    #
    def self.add(config, params)
      return ret if params.nil? || params.empty?
      raise SyntaxError, "Non-empty parameter 'kind' is required" if not params.has_key? "kind"

      susefirewall2 = self.read(params)
      return nil if susefirewall2.nil?

      case params["kind"]
        when "service"
          return add_service(susefirewall2, params)
        else
          raise NotImplementedError, "Unknown kind '#{params["kind"]}'"
      end

    rescue DbusClients::InsufficientPermission => e
      @error = "User has no permission for action '#{e.permission}'."
      return nil
    end

    private

    # add({"service" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    def self.add_service(config, params)
      ret = DEFAULT_RET.dup

      zone     = params["zone"]     || DEFAULT_ZONE
      protocol = params["protocol"] || DEFAULT_PROTOCOL

      key = "FW_SERVICES_#{zone}_#{protocol}".downcase
      # FIXME: ...
      puts config[key]

      return ret
    end

  end
end
