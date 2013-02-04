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

require 'config_agent/script_agent'

module ConfigAgent
  class Runlevel < ConfigAgent::ScriptAgent

    SYSTEMD_MOUNT_DIR   = "/sys/fs/cgroup/systemd"
    RUNLEVEL_TARGET     = "/etc/systemd/system/default.target"

    # read default runlevel
    def read(params)

      # default runlevel for sysvinit:
      out               = run ["/bin/grep", "id:.:initdefault:", "/etc/inittab"]
      default_runlevel  = out["stdout"].split(":")[1] || ""

      log.info "default runlevel for sysvinit: #{default_runlevel}"

      # Check if systemd is in use
      if systemd_used?
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
        log.info "default runlevel for systemd: #{default_runlevel}"
      end
      return default_runlevel
    end

    def write(params)

      ret = {
        "success" => true
      }

      runlevel  = params["runlevel"]
      if runlevel.nil? || (! runlevel.is_a? Integer)
        log.error "wrong argument for runlevel"
        ret["success"]  = false
        return ret
        # TODO raise exception
      end

      # 1. always write init scripts default:
      out = run [ "/bin/sed", "--in-place", "s/^id:.:initdefault:/id:#{runlevel}:initdefault:/g", "/etc/inittab"]
      # 2. write systemd default: create symlink to RUNLEVEL_TARGET
      if systemd_used?
        File.unlink RUNLEVEL_TARGET if File.exists? RUNLEVEL_TARGET
        File.symlink("/lib/systemd/system/runlevel#{runlevel}.target", RUNLEVEL_TARGET)
      end
      # TODO use augeas inittab
      # TODO special handling for runlevel 4 (see RunlevelEd::Write)
    end

  private
    
    def systemd_used?
      return File.directory? SYSTEMD_MOUNT_DIR
    end

  end
end
