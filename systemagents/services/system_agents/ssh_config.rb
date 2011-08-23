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
    
      ret = {}

      aug.match("/files/etc/ssh/ssh_config/*").each do |key_path|
        key	= key_path.split("/").last
        next if key.start_with? "#comment"
	if key.start_with? "Host"
	    # read Host submap
	    ret["Host"]	= [] unless ret.has_key? "Host"
	    host	= {
		"Host"	=> aug.get(key_path)
	    }
	    aug.match(key_path + "/*").each do |host_path|
		host_key = host_path.split("/").last
		next if host_key.start_with? "#comment"
		if host_key == "SendEnv"
		    host[host_key] = read_send_env(aug, host_path)
		else
		    host[host_key] = aug.get(host_path)
		end
	    end
	    ret["Host"].push host
	elsif key == "SendEnv"
	    ret[key]	= read_send_env(aug, key_path)
	else
	    ret[key]	= aug.get(key_path)
	end
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
