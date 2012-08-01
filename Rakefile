require "rake"
require "packaging"

desc "install all things on system"
task :install do
  for client in Dir["gloves*"]
    sh "cd #{client}/ && rake install;cd -" if File.exist?(File.join(client,"Rakefile"))
  end
  for agent in Dir["config_*"]
    sh "cd #{agent} && rake install;cd -" if File.exist?(File.join(agent,"Rakefile"))
  end
  sh "cd libconfigagent/ && rake install; cd -"
end
