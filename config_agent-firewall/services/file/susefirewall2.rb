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

require 'config_agent_service/file_service'
require 'augeas'

class Susefirewall2 < ConfigAgentService::FileService

  FIREWALL_FILE = "/etc/sysconfig/SuSEfirewall2"
  FIREWALL_PATH = "/files#{FIREWALL_FILE}"

  def read(params)
    aug = load_augeas(params)

    firewall = {}

    unless aug.get("/augeas#{FIREWALL_PATH}/error").nil?
      aug.close
      return firewall
    end

    aug.match("#{FIREWALL_PATH}/*").each do |key_path|
      key = key_path.split("/").last
      next if key.start_with? "#comment"
      firewall[key] = aug.get(key_path)
    end

    aug.close
    return firewall
  end

  def write(params)
    aug = load_augeas(params)

    ret = {
      "success" => true
    }

    params.each do |key, value|
      next if key.start_with? "_" # skip internal keys
      aug.set("#{FIREWALL_PATH}/#{key}", value)
    end

    unless aug.save
      ret["success"] = false
      ret["message"] = aug.get("/augeas#{FIREWALL_PATH}/error/message")
    end

    aug.close
    return ret
  end

  private

  def load_augeas(params)
    aug = params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
    aug.transform(:lens => "Sysconfig.lns", :incl => FIREWALL_FILE)
    aug.load

    return aug
  end

end
