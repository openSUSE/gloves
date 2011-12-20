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

require 'config_agent_service/script_service'
require 'tempfile'

class Chpasswd < ConfigAgentService::ScriptService

  def execute(params)


    ret = {}

    user      = params["user"] || ""
    pw        = params["pw"] || ""
    unless (user.empty? && pw.empty?)
      f = Tempfile.new('pwchange','/root')
      begin
        f.puts("#{user}:#{pw}")
        ret = run ["/usr/sbin/chpasswd", f.path]
      ensure
        f.close
        f.unlink
      end
    end

    return ret
  end

end
