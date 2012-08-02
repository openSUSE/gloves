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
  class Adjtime < ConfigAgent::FileAgent

    FILE_PATH = "/etc/adjtime"

    def read(params)

      aug = load_augeas(params)

      ret = {} 

      unless aug.get("/augeas/files#{FILE_PATH}/error").nil?
        aug.close
        return ret
      end

      aug.match("/files#{FILE_PATH}/*").each do |key_path|
        key = key_path.split("/").last
        ret[key] = aug.get(key_path)
      end

      aug.close
      return ret
    end

    def write(params)
      
      ret = {
        "success" => true
      }
      aug = load_augeas(params)

      params.each do |key, value|
        aug.set("/files#{FILE_PATH}/#{key.to_i}", value) unless key.to_i == 0
      end

      unless aug.save
        ret["success"] = false
        ret["message"] = aug.get("/augeas/files#{FILE_PATH}/error/message")
      end

      aug.close
      return ret
    end

  private
    
    def load_augeas(params)
      aug = params["_aug_internal"] || Augeas::open(nil, ConfigAgent::Constant::LENSES_DIR, Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Adjtime.lns", :incl => FILE_PATH)
      aug.load
      return aug
    end
  
  end
end
