#--
# Gloves Timezone Library
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

require "rubygems"
require 'config_agent/adjtime'
require 'config_agent/clock'
require 'config_agent/script_agent'

# module for timezone configuration
module Glove
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
      	return {
	    "timezones"	=> read_timezones
	}
      # return the hash mapping regions to time zones
      elsif (params["kind"] == "regions")
        full_timezones  = read_timezones_with_regions
        region          = params["only"]
        unless region.nil?
          return full_timezones[region] if full_timezones && full_timezones.has_key?(region)
          # log.error = "No such region: '#{region}'"
          return {}
        else
          return full_timezones
        end
      # return current time
      elsif (params["kind"] == "time")
        return current_time
      # return default timezone for given language
      elsif (params["kind"] == "language")
        return timezone_for_language(params["language"] || "en_US")
      end

      sysconfig_timezone        = read_sysconfig
      return nil if sysconfig_timezone.nil?

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

      # read original sysconfig values
      sysconfig_timezone        = read_sysconfig
      return nil if sysconfig_timezone.nil?

      timezone  = params["timezone"]
      hwclock   = params["hwclock"]

      # fill timezone/hwclock if it wasn't provided
      if hwclock.nil? || timezone.nil?
        hwclock = sysconfig_timezone["HWCLOCK"] if hwclock.nil?
        timezone= sysconfig_timezone["TIMEZONE"] if timezone.nil?
      end

      # only set time
      if (config["time"])
        set_time(timezone,hwclock,params)
        return ret
      end

      # write sysconfig values (if provided)
      unless params.nil? && params.empty? && (!config["only_apply"])
	sysconfig_params = {}
	params.each do |key, value|
      	  new_key = @sysconfig2yast.invert[key]
      	  sysconfig_params[new_key] = value unless new_key.nil?
	end

        if sysconfig_params.has_key? "HWCLOCK"
          adjtime_f = ConfigAgent::Adjtime.new
          adjtime = adjtime_f.read({})
          adjtime = { "1" => "0.0 0 0.0", "2" => "0" } if adjtime.empty?
          adjtime["3"]    = sysconfig_params.delete "HWCLOCK"
          adjtime_f.write(adjtime)
        end

        ret	= ConfigAgent::Clock.new.write(sysconfig_params)
      end

      # apply the time zone changes to the system
      if config["apply"] || config["only_apply"]
	ConfigAgent::ScriptAgent.new.run ["/usr/sbin/zic","-l",  timezone]
        unless `uname -m`.start_with?("s390")
          # synchronize hw clock to system clock
	  ConfigAgent::ScriptAgent.new.run ["/sbin/hwclock"," --hctosys", hwclock]
        end
      end

      # call mkinitrd if hwclock was changed or timezone was changed while localtime is in use
      if (hwclock != sysconfig_timezone["HWCLOCK"] ||
         (hwclock == "--localtime" && timezone != sysconfig_timezone["TIMEZONE"]))
          ConfigAgent::ScriptAgent.new.run ["/sbin/mkinitrd"]
      end

      return ret
    end


  private

    # read data from /etc/sysconfig/clock and /etc/adjtime
    def self.read_sysconfig
      read = ConfigAgent::Clock.new.read({})

      adjtime = ConfigAgent::Adjtime.new.read({})
      if (adjtime.has_key? "3")
        read["HWCLOCK"]  = (adjtime["3"] == "LOCAL") ? "--localtime" : "-u"
      end
      return read
    end

    # return current system time
    def self.current_time
      time    = ConfigAgent::ScriptAgent.new.run ["/bin/date","+%Y-%m-%d - %H:%M:%S"]
      return {
        "time"      => time["stdout"] || ""
      }
      # TODO compute time when timezone was not saved to system yet
      # See Timezone::GetDateTime (false, )
    end

    # return the default time zone for given language, language is locale form, like en_US, de_DE
    # TODO ask Language Glove for data
    def self.timezone_for_language(language)
      # split("\n") is for multiple results for input like 'en'
      line = `grep timezone /usr/share/YaST2/data/languages/*#{language}*.ycp 2>/dev/null`.chop.split("\n")
      timezone  = line[0].gsub(/^[^"]*"[^"]+"[^"]*"([^"]+)".*$/,"\\1") if line.size > 0
      return {
        "timezone"      => timezone || ""
      }
    end

    # Read all the timezones splitted into regions also read timezone labels
    # return hash scructure of kind { region => { timezone => label } }
    # Regions are defined in YaST data file; if not present, take reasons from zone.tab
    def self.read_timezones_with_regions
      full      = {}
      region    = ""
      unless File.exists? YAST_TIMEZONES
        # use regions from time zonne names (defined in ZONETAB)
        read_timezones.each do |timezone|
          region,zone   = timezone.split("/")
          full[region]  = {} unless full.has_key?(region)
          full[region][timezone]    = zone
        end
        return full
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

    # read all available time zones; return list of strings
    def self.read_timezones
      return [] unless File.exists? ZONETAB
      return `grep -v "#" #{ZONETAB} | cut -f 3 | sort`.split("\n")
    end

    def self.utc_only?
      machine = `uname -m`.chop
      return machine.start_with?("sparc")
      # TODO how to do checks that are in YCP?
      # Arch::board_iseries () || Arch::board_chrp () || Arch::board_prep 
    end

    # adapt current time
    def self.set_time(timezone,hwclock,p)
        return if `uname -m`.start_with?("s390")

        args    = ["/sbin/hwclock", "--set", hwclock,
          "--date=\"#{p['month']}/#{p['day']}/#{p['year']} #{p['hour']}:#{p['minute']}:#{p['second']}\""]

#        if (hwclock != "--localtime" && timezone)
#            # FIXME env variable, how to pass it?
#            args        = ["TZ=#{timezone}"] + args
#        end

        # set the HW clock
	ConfigAgent::ScriptAgent.new.run args
        # synchronize to system clock
	ConfigAgent::ScriptAgent.new.run ["/sbin/hwclock", "--hctosys", hwclock]

    end
  end
end
