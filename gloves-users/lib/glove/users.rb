#--
# Gloves Users Library
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

$LOAD_PATH << File.dirname(__FILE__)

require "rubygems"
require 'config_agent/passwd'
require 'config_agent/chpasswd'
require 'config_agent/script_agent'

# module for users configuration
module Glove
  module Users

    def self.last_error
      return @error
    end

    # Read all settings relevant for Users configuration
    def self.read(params)
      ret       = {}

      begin
        ret     = ConfigAgent::Passwd.new.read(params)
      rescue DbusClients::InsufficientPermission => e
        @error	= "User has no permission for action '#{e.permission}'."
        return nil
      end
      return ret;
    end

    # add a new user
    def self.add(config, params)

      ret		= {
    	"success"	=> true
      }

      username  = params["username"]
      if username.nil?
        @error  = "Username not provided"
        return nil
      end

      useradd = ["/usr/sbin/useradd", username]

      useradd = useradd + [ "-c", params["comment"] ]   if params["comment"]
      useradd = useradd + [ "-d", params["home"] ]      if params["home"]
      useradd = useradd + [ "-m" ]                      if params["create_home"]
      useradd = useradd + [ "-u", params["uid"].to_s ]  if params["uid"]
      useradd = useradd + [ "-g", params["gid"].to_s ]  if params["gid"]
      useradd = useradd + [ "-s", params["shell"] ]     if params["shell"]
      useradd = useradd + [ "--system" ]                if params["system"]

      ret = ConfigAgent::ScriptAgent.new.run useradd

      if ret["exit"] == 0 && params["password"]
        ret = ConfigAgent::Chpasswd.new.execute({ "user" => username, "pw" => params["password"]})
      end

      if ret["exit"] == 0
        ret = ConfigAgent::ScriptAgent.new.run ["/usr/sbin/useradd.local", username]
      end

      return ret

    rescue DbusClients::InsufficientPermission => e
      @error	= "User has no permission for action '#{e.permission}'."
      return nil
    end

    # modify existing user
    def self.modify(config,params)

      ret		= {
    	"success"	=> true
      }
      return ret
    rescue DbusClients::InsufficientPermission => e
      @error	= "User has no permission for action '#{e.permission}'."
      return nil
    end

  private

  end
end
