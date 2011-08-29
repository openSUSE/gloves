require "rake"
require "packaging"

desc "install all things on system"
task :install do
  sh "cd kerberos-client-api/ && rake install;cd -"
  sh "cd config_agents/ && rake install;cd -"
  sh "cd libconfigagent/ && rake install; cd -"
end
