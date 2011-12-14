#!/usr/bin/env ruby

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

$stdout.reopen("/var/log/config_agents/service.stdout")
$stderr.reopen("/var/log/config_agents/service.stderr")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','..',"services")
require "rubygems"
require "dbus"
require "config_agent_service/policykit_checker"
require "config_agent_service/logger"
require "config_agent_service/backend_exception"

SERVICE_NAME="org.opensuse.config_agent"
OBJECT_PATH="/org/opensuse/config_agent"
INTERFACE_NAME="org.opensuse.config_agent"
SERVICE_PATH="/usr/share/config_agents/services"
KNOWN_TYPES = ["file","script"]
PERMISSION_PREFIX="org.opensuse.config_agent"
TIMEOUT = 60 #in seconds

module Sync
  def self.last_call
    @time ||= Time.now
  end
  def self.last_call=(val)
    mutex.synchronize do
      @time = val
    end
  end

  def self.mutex
    @mymutex ||= Mutex.new
  end
end

class ConfigAgentDbusService < DBus::Object
  include ConfigAgentService::Logger
  include ConfigAgentService::PolicykitChecker

  def mutex=(m)
    @my_mutex = m
  end
  def dispatch(msg)
    msg.params << msg.sender
    log.info msg.params.inspect
    super(msg)
  end

  dbus_interface(INTERFACE_NAME) do
    dbus_method :call, "out result:a{sv}, in id:s, in method:s, in data:a{sv}" do |id,method,data,sender|
      #at first ensure permission is given
      begin
        Sync.last_call = Time.now
        check_permissions sender, id+"."+method, data 
        [ConfigAgentDbusService.call_method(id,method,data)]
      rescue ConfigAgentService::BackendException => e
          [ e.to_hash ]
      rescue Exception => e
          [{ "error" => e.message, "backtrace" => e.backtrace.join("\n") }]
      end
    end
  end

  def self.call_method id,method,data
    method = method.to_sym
    #TODO check agains whitelist if id conform expectation
    parts = id.split(".")
    type = parts[-2]
    return { "error" => "not allowed type '#{type}'" } unless KNOWN_TYPES.include?(type)
    service = parts[-1]
    file_path = File.join(SERVICE_PATH,type,service+".rb")
    if !File.exist? file_path
      return { "error" => "missing service for id #{id}" } 
    end
    require file_path
    class_name = service.gsub(/(^|_)(.)/) { $2.upcase }
    obj = Kernel.const_get(class_name.to_sym).new
    return { "error" => "unknown method for class" } unless obj.respond_to? method
    return obj.send(method,data)
  end
end




# Choose the bus (could also be DBus::session_bus, which is not suitable for a system service)
bus = DBus::system_bus
# Define the service name
service = bus.request_service(SERVICE_NAME)
# Set the object path
obj = ConfigAgentDbusService.new(OBJECT_PATH)
# Export it!
service.export(obj)

# Now listen to incoming requests
main = DBus::Main.new
main << bus

Thread.new(main) do |dbus_loop|
  cont = true
  while cont do
    sleep(TIMEOUT/2)
    Sync.mutex.synchronize do
      if Time.now - Sync.last_call > TIMEOUT
        exit 0
      end
    end
  end
end

main.run
