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

require 'dbus_services/script_service'

module ConfigAgent
  class PamConfig < DbusServices::ScriptService

    # identification of relevant DBUS service
    agent_id "usr_sbin_pam_config"

    def execute(params)
      exec_params	= params["exec_params"] || ""
      run "/usr/sbin/pam-config #{exec_params}" #FIXME escape parameters
    end
  end
end
