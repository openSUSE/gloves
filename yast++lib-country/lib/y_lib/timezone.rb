#--
# YaST++ Timezone Library
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

require 'config_agent/clock'

# module for timezone configuration
module YLib
  module Timezone

    def self.last_error
      return @error
    end

    YAST_TIMEZONES      = "/usr/share/YaST2/data/timezone_raw.ycp"
    ZONETAB             = "/usr/share/zoneinfo/zone.tab"

    @sysconfig2yast	= {
      "TIMEZONE"	=> "timezone",
      "HWCLOCK"		=> "hwclock",
      "DEFAULT_TIMEZONE"=> "default_timezone"
    }

    # Read all settings relevant for timezone configuration
    def self.read(params)

      # get the list of available time zones
      if (params["kind"] == "timezones")
        return {} unless File.exists? ZONETAB
	timezones = `grep -v "#" #{ZONETAB} | cut -f 3 | sort`.split("\n")
      	return {
	    "timezones"	=> timezones
	}
      # return the hash mapping regions to time zones
      elsif (params["kind"] == "regions")
        full_timezones  = read_timezones_with_regions
        region          = params["only"]
        unless region.nil?
          return full_timezones[region] if full_timezones.has_key? region
          # log.error = "No such region: '#{region}'"
          return {}
        else
          return full_timezones
        end
      end

      # read config files
      begin
        sysconfig_timezone	= ConfigAgent::Clock.read({})
      rescue DbusClients::InsufficientPermission => e
        @error	= "User has no permission for action '#{e.permission}'."
        return nil
      end

      ret	= {}
      sysconfig_timezone.each do |key, val|
      	ret[@sysconfig2yast[key]]	= val if @sysconfig2yast.has_key? key
      end
      return ret
    end

    # Write Timezone configuration
    def self.modify(config,params)

      ret		= {
	"success"	=> true
      }
      unless params.nil? && params.empty?
	sysconfig_params = {}
	params.each do |key, value|
      	  new_key = @sysconfig2yast.invert[key]
      	  sysconfig_params[new_key] = value unless new_key.nil?
	end
        ret	= ConfigAgent::Clock.write(sysconfig_params)
      end

      if config.has_key? "apply" && config["apply"]
      	timezone	= params["timezone"] # FIXME read it if it wasn't provided?
	ConfigAgent::Zic.execute({ "exec_args" => ["-l",  timezone] }) unless timezone.nil?
	hwclock		= params["hwclock"]
	ConfigAgent::Hwclock.execute({ "exec_args" => [" --hctosys", hwclock]}) unless hwclock.nil?
      end

      # TODO set time
      # TODO sync sys to hwclock
      # TODO mkinitrd call

      return ret
    rescue DbusClients::InsufficientPermission => e
      @error	= "User has no permission for action '#{e.permission}'."
      return nil
    end


  private

    # read all the timezones splitted into regions defined by YaST, also read timezone labels
    # return hash scructure of kind { region => { timezone => label } }
    def self.read_timezones_with_regions
      full      = {}
      region    = ""
      unless File.exists? YAST_TIMEZONES
        @error  = "File #{YAST_TIMEZONES} does not exist"
        return nil
      end
      input = `grep ":" #{YAST_TIMEZONES} | sed 's/^[[:space:]]*//'`
      input.split("\n").each do |line|
        next if (line.start_with?("*") || line.start_with?('"entries"') || line.start_with?('"central"'))
        # take key and value from inside the quotes
        key,val = line.gsub(/^[^"]*"([^"]+)"[^"]*"([^"]+)".*$/,"\\1:\\2").split(':')
        if key == "name"
          region = val
          full[region]  = {}
        else
          full[region][key]     = val
        end
      end
      return full
    end

  end
end
