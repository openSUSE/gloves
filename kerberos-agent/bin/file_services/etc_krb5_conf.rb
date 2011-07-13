#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__),'..','..',"services")
require "system_agents/krb_conf"
require "service_runner"
ServiceRunner::run(SystemAgents::KrbConf)
