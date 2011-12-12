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

$stdout.reopen("/var/log/systemagent.stdout")
$stderr.reopen("/var/log/systemagent.stderr")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','..',"services")
require "rubygems"
require "config_agent_service/susefirewall2"
require "dbus_services/service_runner"
DbusServices::ServiceRunner::run(ConfigAgentService::Susefirewall2)
