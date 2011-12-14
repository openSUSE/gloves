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

module ConfigAgentService
  class Windowmanager < DbusServices::FileService

    # identification of relevant DBUS service
    agent_id "etc_sysconfig_windowmanager"


    def readiii(params)

	my_file = File.new("/tmp/yastdebug", APPEND)
	my_file.puts "newline"


      return "ConfigAgent"

      aug               = params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "windowsmanager.lns", :incl => "/etc/sysconfig/windowmanager")
      aug.load

      default_wm = aug.get("/files/etc/sysconfig/windowmanager/DEFAULT_WM")

      windowmanager_conf = {
        "default_wm" => default_wm
      }
      aug.close

      return windowmanager_conf
    end

    def write(params)
      #TODO add your code here
      return {}
    end

  end
end
