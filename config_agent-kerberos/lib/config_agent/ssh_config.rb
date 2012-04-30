#--
# Config Agents Framework
#
# Copyright (C) 2011 Novell, Inc.
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 or version 3 of the GNU Lesser General Public
# License as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require 'config_agent/file_agent'
require "augeas"

module ConfigAgent
  class SshConfig < ConfigAgent::FileAgent

    def read(params)
      aug		= params["_aug_internal"] || Augeas::open(nil, "/usr/share/augeas/lenses/", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Ssh.lns", :incl => "/etc/ssh/ssh_config")
      aug.load

      ret = {
        # we have to create list (not hash), because order matters
        "Host"	=> []
      }

      aug.match("/files/etc/ssh/ssh_config/Host").each do |host_path|

        host	= {
          "Host"	=> aug.get(host_path)
        }
        # read Host submap
        aug.match(host_path + "/*").each do |key_path|

          key = key_path.split("/").last
          next if key.start_with? "#comment"
          if key.start_with? "SendEnv"
            host[key] = read_send_env(aug, key_path)
          else
            host[key] = aug.get(key_path)
          end
        end
        ret["Host"].push host
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

      # currently we support updating the Host section
      if params.has_key? "Host"
        hosts	= params["Host"]
        first_host = nil
        # convert hosts list to a hash for better searching
        hosts_hash	= {}
        hosts.each do |host|
          h		= host.dup
          name	= h.delete "Host"
          hosts_hash[name]	= h
        end
        # iterate over existing hosts
        aug.match("/files/etc/ssh/ssh_config/Host").each do |host_path|
          host = aug.get(host_path)
          first_host	= host_path unless first_host
          if hosts_hash.has_key? host
            args	= hosts_hash.delete host
            write_host_args(aug, host_path, args)
          end
        end
        # given host section was not found in current file: should be added
        unless hosts_hash.empty?
          hosts.each do |args|
            # add new host to the top of the file
            aug.insert(first_host,"Host",true)
            path = "/files/etc/ssh/ssh_config/Host[1]"
            new_host	= args.delete "Host"
            aug.set(path, new_host)
            write_host_args(aug, path, args)
          end
        end
      end

      unless aug.save
        ret["success"]	= false
        ret["message"]	= aug.get("/augeas/files/etc/ssh/ssh_config/error/message")
      end

      aug.close
      return ret
    end

  private

    # read list of values for SendEnv
    # arguments are augeas object and path to SendEnv key
    def read_send_env aug, path
      aug.match(path + "/*").reduce([]) do |acc,send_env_path|
        acc << aug.get(send_env_path)
      end
    end

    # write values into given Host section
    def write_host_args aug, host_path, args

      args.each do |key, value|
        if value.nil? || value.empty?
          aug.delete(host_path + "/" + key)
        elsif value.is_a? Array
          i = 1
          value.each do |v|
            aug.set(host_path + "/" + key + "/" + i.to_s , v)
      i = i + 1
    end
        else
          aug.set(host_path + "/" + key, value)
        end
      end
    end
  end
end
