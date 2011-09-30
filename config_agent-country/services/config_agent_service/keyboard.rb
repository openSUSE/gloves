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

require 'dbus_services/file_service'
require 'augeas'

module ConfigAgentService
  class Keyboard < DbusServices::FileService

    # identification of relevant DBUS service
    agent_id "etc_sysconfig_keyboard"

    def read(params)
      aug		= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Sysconfig.lns", :incl => "/etc/sysconfig/keyboard")
      aug.load

      keyboard	= {}

      # possible error: parse_failed
      unless aug.get("/augeas/files/etc/sysconfig/keyboard/error").nil?
	aug.close
	return keyboard
      end
	
      aug.match("/files/etc/sysconfig/keyboard/*").each do |key_path|
        key	= key_path.split("/").last
	next if key.start_with? "#comment"
	keyboard[key]	= aug.get(key_path)
      end
      aug.close
      return keyboard
    end

    def write(params)
      #TODO add your code here
      return {}
    end

  end
end
