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

require 'config_agent/file_agent'
require 'augeas'

module ConfigAgent
  class Passwd < ConfigAgent::FileAgent

    PASSWD_FILE = '/etc/passwd'

    # read users from /etc/passwd
    def read(params)

      aug        	= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Passwd.lns", :incl => PASSWD_FILE)
      aug.load

      ret         = {}
      retlist     = []

      # possible error: parse_failed
      unless aug.get("/augeas/files#{PASSWD_FILE}/error").nil?
        aug.close
        return ret
      end

      only = params["only"]
      unless params["id"].nil?
        ret       = read_one_user(aug, "/files#{PASSWD_FILE}/" + params["id"])
      else
        # read all users
        aug.match("/files#{PASSWD_FILE}/*").each do |user_path|
          user      = user_path.split("/").last
          next if user.start_with? "#comment"
          # when 'only' is specified, we return list of values, not hash
          unless only.nil?
            if (only == "username" || only == "login")
              val = user
            else
              val = aug.get("#{user_path}/#{only}")
            end
            retlist << val unless val.nil?
          else
            ret[user]      = read_one_user(aug, user_path)
          end
        end
      end

      aug.close
      unless only.nil?
        ret = {
          "result" => retlist
        }
      end
      return ret
    end

    def write(params)
      #TODO add your code here
      return {}
    end

    private

    # read the data about one user from /etc/passwd
    def read_one_user aug, user_path
      u   = {}
      aug.match(user_path + "/*").each do |key_path|
        key     = key_path.split("/").last
        val     = aug.get(key_path)
        u[key]  = val unless val.nil?
      end
      return u
    end

  end
end
