#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__),'..','..',"services")
require "system_agents/krb_conf"
ServiceRunner::run(SystemAgents::KrbConf)
