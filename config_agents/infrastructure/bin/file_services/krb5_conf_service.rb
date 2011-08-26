#!/usr/bin/env ruby
$stdout.reopen("/var/log/systemagent.stdout")
$stderr.reopen("/var/log/systemagent.stderr")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','..',"services")
require "rubygems"
require "system_agent/krb5_conf"
require "dbus_services/service_runner"
DbusServices::ServiceRunner::run(SystemAgents::Krb5Conf)