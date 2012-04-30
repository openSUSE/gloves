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
require 'tempfile'

module ConfigAgent
  class Chpasswd < ConfigAgent::ScriptAgent

    def execute(params)
      ret = {}

      config = params["config_file"] || [params] #allow one hash with user+pass or array of values
      correct_data = config.all? {|i| !(i["user"]).empty? && !(i["pw"]).empty? }
      return ret unless correct_data #TODO exception

      f = Tempfile.new('pwchange','/root')
      begin
        config.each { |i| f.puts("#{i["user"]}:#{i["pw"]}") }
        ret = run(["/usr/sbin/chpasswd"]+(params["exec_args"]||[])+[f.path])
      ensure
        f.close
        f.unlink
      end

      return ret
    end

  end
end
