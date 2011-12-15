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
require 'augeas'

class Keyboard < ConfigAgentService::FileService

  def read(params)
    aug        	= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
    aug.transform(:lens => "Sysconfig.lns", :incl => "/etc/sysconfig/keyboard")
    aug.load

    keyboard        = {}

    # possible error: parse_failed
    unless aug.get("/augeas/files/etc/sysconfig/keyboard/error").nil?
      aug.close
      return keyboard
    end

    aug.match("/files/etc/sysconfig/keyboard/*").each do |key_path|
      key        = key_path.split("/").last
      next if key.start_with? "#comment"
      keyboard[key]	= aug.get(key_path)
    end
    aug.close
    return keyboard
  end

  def write(params)
    aug        	= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
    # different lens for writing, because of double quote handling...
    aug.transform(:lens => "Shellvars.lns", :incl => "/etc/sysconfig/keyboard")
    aug.load
    ret        = {
      "success"	=> true
    }

    path        = "/files/etc/sysconfig/keyboard/"
    params.each do |key, value|
      next if key.start_with? "_" # skip internal keys
      value = "\"" + value + "\""
      aug.set(path + key, value)
    end

    unless aug.save
      ret["success"]	= false
      ret["message"]	= aug.get("/augeas/files/etc/sysconfig/keyboard/error/message")
    end

    aug.close
    return ret
  end

end
