#!/usr/bin/env ruby
$stdout.reopen("/var/log/systemagent.stdout")
$stderr.reopen("/var/log/systemagent.stderr")
$LOAD_PATH << File.join(File.dirname(__FILE__),'..','..',"services")
require "system_agents/krb5_conf"
require "dbus_services/service_runner"
DbusServices::ServiceRunner::run(SystemAgents::Krb5Conf)
