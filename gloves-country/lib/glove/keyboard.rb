#--
# Gloves Keyboard Library
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

require 'config_agent/keyboard'
require 'config_agent/setxkbmap'
require 'config_agent/loadkeys'

# module for keyboard configuration
module Glove
  module Keyboard

    def self.last_error
      return @error
    end

    @sysconfig_values = [
    	"KBD_TTY",
	"KBD_RATE",
	"KBD_DELAY",
	"KBD_NUMLOCK",
	"KBD_CAPSLOCK",
	"KBD_SCRLOCK",
	"KBD_DISABLE_CAPSLOCK"
    ]

    # Read all settings relevant for keyboard configuration (key:value map).
    def self.read(params)

      # read config files
      begin
        sysconfig_keyboard	= ConfigAgent::Keyboard.read({})
      rescue DbusClients::InsufficientPermission => e
        @error	= "User has no permission for action '#{e.permission}'."
        return nil
      end

      ret	= {}
      sysconfig_keyboard.each do |key, val|
      	ret[key.downcase]	= val if @sysconfig_values.include? key
      end
      ret["compose_table"]	= sysconfig_keyboard["COMPOSETABLE"] || ""
      ret["keymap"]		= sysconfig_keyboard["KEYTABLE"] || ""

      yast_kbd	= sysconfig_keyboard["YAST_KEYBOARD"] || ""
      current	= yast_kbd.split(",")
      if current.size == 2
	ret["current_kbd"] = current[0]
      	ret["kb_model"]	= current[1]
      end
      return ret
    end

    # Write Keyboard configuration
    def self.modify(config,params)

      ret       = {
	"success"	=> true
      }

      keymap    = ""

      # write sysconfig settings
      unless params.nil? && params.empty?
	sysconfig_params = {}
	params.each do |key, value|
      	  sysconfig_params[key.upcase] = value if @sysconfig_values.include? key.upcase
	end
        if params.has_key?("current_kbd") && params.has_key?("kb_model")
	  sysconfig_params["YAST_KEYBOARD"]     = (params["current_kbd"] || "") + "," + (params["kb_model"] || "")
        end
        ret["COMPOSETABLE"]	= params["compose_table"] if params.has_key? "compose_table"
        if params.has_key? "keymap"
          keymap                = params["keymap"]
          sysconfig_params["KEYTABLE"]  = keymap
        end
        ret	= ConfigAgent::Keyboard.write(sysconfig_params)
      end

      # set the new keyboard layout for console and X11
      if config["apply"] && keymap
        # TODO: if keymap is empty, find out from current_kbd value and data from keyboard_raw.ycp
        if File.exists?("/usr/sbin/xkbctrl")
          apply = `/usr/sbin/xkbctrl #{keymap} | grep Apply`
          apply = apply[apply.index(":") + 1 ..apply.size].gsub(/"/,"").chop
          ConfigAgent::Setxkbmap.execute({
              "DISPLAY" => ENV["DISPLAY"] || "",
              "exec_args" => apply.split }
          ) unless apply.empty?
        end
        # FIXME pick correct console font!
        ConfigAgent::Loadkeys.execute({ "exec_args" => [ keymap ] })
      end

      return ret
    rescue DbusClients::InsufficientPermission => e
      @error	= "User has no permission for action '#{e.permission}'."
      return nil
    end


  end
end
