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
      aug		= params["_aug_internal"] || Augeas::open(nil, "/tmp/lens", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Ssh.lns", :incl => "/etc/ssh/ssh_config")
      aug.load

      ret	= {
	"success"	=> true
      }

      # only modified parts provided
      if params.has_key? "update"
	update	= params["update"]
	first_host = nil
	# iterate over existing hosts
	aug.match("/files/etc/ssh/ssh_config/Host").each do |host_path|
	    host = aug.get(host_path)
	    first_host	= host_path unless first_host
	    if update.has_key? host
		args	= update.delete host
		write_host_args(aug, host_path, args)
	    end
	end
	# host section was not found: should be added
	unless update.empty?
	    update.each do |new_host, args|
		# add new host to the top of the file
		aug.insert(first_host,"Host",true)
		path = "/files/etc/ssh/ssh_config/Host[1]"
		aug.set(path, new_host)
		write_host_args(aug, path, args)
	    end
	end
      elsif params.has_key? "ssh_config"
	# Here, it should be possible to pass whole new list covering the config file, 
	# same format as the output of read.
	# Everything should be written
	ret["message"]	= "Not implemented"
	aug.close
	return ret
      else
	ret["message"]	= "Wrong format of input parameters"
	ret["success"]	= false
	aug.close
	return ret
      end

      unless aug.save
	ret["success"]	= false
	ret["message"]	= aug.get("/augeas/files/etc/krb5.conf/error/message")
      end

      aug.close
      return ret
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

    # write values into given Host section
    def write_host_args aug, host_path, args

      args.each do |key, value|
	if value.nil? || value.empty?
	    aug.delete(host_path + "/" + key)
	else
	    aug.set(host_path + "/" + key, value)
	end
      end
    end

  end
end
