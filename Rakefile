require "rake"
require "packaging"

desc "install all things on system"
task :install do
  for client in Dir["yast++lib*"]
    sh "cd #{client}/ && rake install;cd -"
  end
  for agent in Dir["config_*"]
    sh "cd #{agent} && rake install;cd -"
  end
  sh "cd libconfigagent/ && rake install; cd -"
end
