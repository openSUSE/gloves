require "rake"

desc "install all things on system"
task :install do
  sh "cd systemagents/;rake install;cd -"
  sh "cp -r dbus_clients dbus_services /usr/lib*/ruby/vendor_ruby/1.*/"
end
