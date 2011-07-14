#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__),'..','..',"services")
require "system_agents/krb_conf"
require "dbus_services/service_runner"
DbusServices::ServiceRunner::run(SystemAgents::KrbConf)
