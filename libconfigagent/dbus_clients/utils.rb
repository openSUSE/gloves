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
require 'config_agent_service/backend_exception'

module DbusClients
  module Utils
    #taken from active support for automagic
    def self.underscore input
      input.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    BACKEND_LOCATION = "/usr/share/config_agents/services"
    def self.direct_call class_name, type, method, params
      $LOAD_PATH << BACKEND_LOCATION
      base_name = class_name.split('::').last
      module_path = underscore base_name
      begin
        require "#{type}/#{module_path}"
        require "config_agent_service/backend_exception"
        begin
          ret = Kernel.const_get(base_name).send(:new).send(method,params) #name is same
        rescue ConfigAgentService::BackendException => e
          ret = e.to_hash
        end
      ensure
        $LOAD_PATH.pop
      end
      return ret
    end
  end
end
