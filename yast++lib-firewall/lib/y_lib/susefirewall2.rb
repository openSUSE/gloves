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

    CONFIG_DELIMITER = " "

    def self.last_error
      return @error
    end

    #
    # Read all settings relevant for SuSEfirewall2 configuration (key:value map)
    #
    def self.read(params)
      begin
        susefirewall2 = ConfigAgent::Susefirewall2.read({})
      rescue DbusClients::InsufficientPermission => e
        @error = "User has no permission for action '#{e.permission}'."
        return nil
      end

      ret = {}

      case params["kind"] || "all"
        when "open_port"
          ret = handle_open_port(susefirewall2, params, "read")
        when "interface"
          ret = handle_interface_in_zone(susefirewall2, params, "read")
        when "all"
          susefirewall2.each do |key, val|
            ret[key] = val
          end
        else
          raise NotImplementedError, "Unknown kind '#{params["kind"]}'"
      end

      return ret
    end

    #
    # Write SuSEfirewall2 configuration
    #
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
    # To open port in firewall
    #   add({}, {"kind" => "open_port", "port" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    #
    def self.add(config, params)
      check_parameters(params, ["kind"])

      susefirewall2 = self.read({})
      return nil if susefirewall2.nil?

      susefirewall2_previous = susefirewall2.dup

      case params["kind"]
        when "open_port"
          handle_open_port(susefirewall2, params, "add")
        when "interface"
          handle_interface_in_zone(susefirewall2, params, "add")
        else
          raise NotImplementedError, "Unknown kind '#{params["kind"]}'"
      end

      ret = DEFAULT_RET.dup
      ret = ConfigAgent::Susefirewall2.write(susefirewall2) if susefirewall2 != susefirewall2_previous
      return ret

    rescue DbusClients::InsufficientPermission => e
      @error = "User has no permission for action '#{e.permission}'."
      return nil
    end

    #
    # To close port in firewall
    #   remove({}, {"kind" => "open_port", "port" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    #
    def self.remove(config, params)
      check_parameters(params, ["kind"])

      susefirewall2 = self.read({})
      return nil if susefirewall2.nil?

      susefirewall2_previous = susefirewall2.dup

      case params["kind"]
        when "open_port"
          handle_open_port(susefirewall2, params, "remove")
        when "interface"
          handle_interface_in_zone(susefirewall2, params, "remove")
        else
          raise NotImplementedError, "Unknown kind '#{params["kind"]}'"
      end

      ret = DEFAULT_RET.dup
      ret = ConfigAgent::Susefirewall2.write(susefirewall2) if susefirewall2 != susefirewall2_previous
      return ret

    rescue DbusClients::InsufficientPermission => e
      @error = "User has no permission for action '#{e.permission}'."
      return nil
    end

    private

    #
    # Opens a new port
    #   handle_open_port({...current configuration...}, {"action" => "add", "port" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    #
    # Removes a port
    #   handle_open_port({...current configuration...}, {"action" => "remove", "port" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    #
    # Checks whether a port is open
    #   handle_open_port({...current configuration...}, {"action" => "read", "port" => "ssh", "protocol" => "TCP", "zone" => "EXT"})
    #
    # Handles the FW_SERVICES_$ZONE_$PROTOCOL entry
    #
    def self.handle_open_port(config, params, action)
      check_parameters(params, ["port"])
      port     = params["port"]

      # These are optional
      zone     = params["zone"]     || DEFAULT_ZONE
      protocol = params["protocol"] || DEFAULT_PROTOCOL
      key = "FW_SERVICES_#{zone}_#{protocol}".upcase

      return self.read_add_remove(config, params, action, key, port)
    end

    #
    # Opens a new port
    #   handle_interface_in_zone({...current configuration...}, {"action" => "add", "interface" => "eth4", "zone" => "EXT"})
    #
    # Removes a port
    #   handle_interface_in_zone({...current configuration...}, {"action" => "remove", "interface" => "eth4", "zone" => "EXT"})
    #
    # Checks whether a port is open
    #   handle_interface_in_zone({...current configuration...}, {"action" => "read", "interface" => "eth4", "zone" => "EXT"})
    #
    # Handles the FW_DEV_$ZONE entry
    #
    def self.handle_interface_in_zone(config, params, action)
      check_parameters(params, ["interface"])
      interface = params["interface"]

      # Zone is optional
      zone = params["zone"] || DEFAULT_ZONE
      key = "FW_DEV_#{zone}".upcase

      return self.read_add_remove(config, params, action, key, interface)
    end

    #
    # Handles a sysconfig entry separated by whitespaces.
    # Possible actions are 'add', 'remove', and 'read'
    # Parameter key defines the sysconfig entry
    #
    def self.read_add_remove(config, params, action, key, entry)
      val = config[key].split

      if action == "add" && !val.include?(entry)
        val << entry
        config[key] = val.join CONFIG_DELIMITER
        return true
      elsif action == "remove" && val.include?(entry)
        val.delete entry
        config[key] = val.join CONFIG_DELIMITER
        return true
      elsif action == "read"
        if val.include?(entry)
          return params
        else
          return nil
        end
      end
    end

    #
    # Checks existence of mandatory parameters
    # Throws a SyntaxError if some parameter is missing
    #
    #   check_parameters({"params" => "1", "got" => "2"}, ["required", "params"])
    #
    def self.check_parameters(params, required_params)
      raise SyntaxError, "Non-empty parameters are required" if params.nil? || params.empty?

      required_params.each do |key|
        raise SyntaxError, "Non-empty parameter '#{key}' is required" if params[key].nil? || params[key].empty?
      end
    end

  end
end
