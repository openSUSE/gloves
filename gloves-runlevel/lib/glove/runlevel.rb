#--
# Gloves Runlevel Library
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
require 'config_agent/script_agent'
require 'config_agent/runlevel'

# module for runlevel configuration
module Glove
  module Runlevel

    # Read runlevel info
    def self.read(params)
      # read current runlevel
      out               = ConfigAgent::ScriptAgent.new.run ["/sbin/runlevel"]
      current_runlevel  = out["stdout"].split()[1] unless out["stdout"].empty?
      default_runlevel  = ConfigAgent::Runlevel.new.read({})

      ret       = {
        "current"       => current_runlevel || "",
        "default"       => default_runlevel
      }

      return ret;
    end

    # modify runlevel settings
    def self.modify(config,params)

      ret		= {
    	"success"	=> true
      }
      # TODO check if sysvinit or systemd is installed and set runlevel accordingly

      # write init scripts default: sed s/^id:.:initdefault:/id:$rootpart:initdefault:/g /etc/inittab > /etc/inittab.yast2.tmp
      # write systemd default: create symlink to RUNLEVEL_TARGET
      return ret
    end

  private

  end
end
