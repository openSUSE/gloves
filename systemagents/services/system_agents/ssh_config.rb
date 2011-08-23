require 'dbus_services/file_service'
require 'rubygems'
require 'augeas'

module SystemAgents
  class SshConfig < DbusServices::FileService

    # identification of relevant DBUS service
    filename "etc_ssh_ssh_config"


    def read(params)
      aug		= params["_aug_internal"] || Augeas::open(nil, "/tmp/lens", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Ssh.lns", :incl => "/etc/ssh/ssh_config")
      aug.load
    
      ret = {
	"ssh_config"	=> []
      } 

      aug.match("/files/etc/ssh/ssh_config/Host").each do |host_path|

	host	= {
	    "Host"	=> aug.get(host_path)
	}
	# read Host submap
	aug.match(host_path + "/*").each do |key_path|

	    key = key_path.split("/").last
	    next if key.start_with? "#comment"
	    if key == "SendEnv"
		host[key] = read_send_env(aug, key_path)
	    else
		host[key] = aug.get(key_path)
	    end
	end
	ret["ssh_config"].push host
      end

      aug.close
      return ret
    end

    def write(params)
      #TODO add your code here
      return {}
    end

private

    # read list of values for SendEnv
    # arguments are augeas object and path to SendEnv key
    def read_send_env aug, path
      send_env	= []
      aug.match(path + "/*").each do |send_env_path|
	send_env.push aug.get(send_env_path)
      end
      return send_env
    end

  end
end
