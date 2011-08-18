require "rake"
require "packaging"

desc "install all things on system"
task :install do
  sh "cd kerberos-client-api/ && rake install;cd -"
  sh "cd systemagents/ && rake install;cd -"
  sh "cd libsystemagent/ && rake install; cd -"
end
