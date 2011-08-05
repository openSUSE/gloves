require "rake"

desc "install all things on system"
task :install do
  sh "cd kerberos-client-api/;rake install;cd -"
  sh "cd systemagents/;rake install;cd -"
  sh "cp -r dbus_clients dbus_services /usr/lib*/ruby/vendor_ruby/1.*/"
end
