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

require 'config_agent_service/file_service'

class Passwd < ConfigAgentService::FileService

  def read(params)

    aug        	= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
    aug.transform(:lens => "Passwd.lns", :incl => "/etc/passwd")
    aug.load

    passwd = {}

    # possible error: parse_failed
    unless aug.get("/augeas/files/etc/passwd/error").nil?
      aug.close
      return passwd
    end

    aug.match("/files/etc/passwd/*").each do |user_path|
      user      = user_path.split("/").last
      next if user.start_with? "#comment"
      u         = {}
      aug.match(user_path + "/*").each do |key_path|
        key     = key_path.split("/").last
        u[key]  = aug.get(key_path)
      end
      passwd[user]      = u
    end

    aug.close
    return passwd
  end

  def write(params)
    #TODO add your code here
    return {}
  end

end
