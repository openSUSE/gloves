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

require "config_agent/logger"
require "open3"

module ConfigAgent
  # Represent service for executing scripts.
  # @abstract Subclass and implement execute method.
  class ScriptAgent
    include ConfigAgent::Logger

    # Runs given command. Argument processing is without shell using popen call.
    # @arg [Array[String]] command to execute
    # @return [Hash] result of command in map with keys stdout,stderr and exit
    def run command
      ret = {}
      status = Open3::popen3(*command) do |stdin,stdout,stderr,wait_thr|
        stdin.close
        ret["stdout"] = stdout.read.strip
        ret["stderr"] = stderr.read.strip
        ret["exit"] = wait_thr.value.exitstatus
      end
      ret
    end
  end
end
