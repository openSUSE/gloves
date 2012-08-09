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

# module for runlevel configuration
module Glove
  module Runlevel

    SYSTEMD_MOUNT_DIR   = "/sys/fs/cgroup/systemd"
    RUNLEVEL_TARGET     = "/etc/systemd/system/default.target"

    # Read runlevel info
    def self.read(params)
      # read current runlevel
      out               = ConfigAgent::ScriptAgent.new.run ["/sbin/runlevel"]
      current_runlevel  = out["stdout"].split()[1] unless out["stdout"].empty?
      default_runlevel  = read_default_runlevel

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

    # read default runlevel (based on current init system)
# FIXME move whole function to config agent, so File calls could be chrooted
    def self.read_default_runlevel

      # default runlevel for sysvinit:
      out               = ConfigAgent::ScriptAgent.new.run ["/bin/grep", "id:.:initdefault:", "/etc/inittab"]
      default_runlevel  = out["stdout"].split(":")[1] || ""

      # Check if systemd is in use
      if File.directory? SYSTEMD_MOUNT_DIR
        # default runlevel for systemd
        target  = File.readlink(RUNLEVEL_TARGET)
        return default_runlevel if target.nil?
        # target is something like /lib/systemd/system/runlevel5.target
        runlevel        = target.gsub(/^[a-zA-Z\/]*\/([^\/]+)\.target.*$/,"\\1")
        if runlevel.start_with? "runlevel"
          default_runlevel      = runlevel.gsub(/^runlevel/,"")
        else
          # map the symbolic names to runlevel numbers
          mapping       = {
            "poweroff"          => "0",
            "rescue"            => "1",
            "multi-user"        => "3",
            "graphical"         => "5",
            "reboot"            => "6"
          }
          default_runlevel      = mapping[runlevel] || default_runlevel
        end
       end
      return default_runlevel
    end

  end
end
