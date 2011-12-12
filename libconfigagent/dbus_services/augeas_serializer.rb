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

require "augeas"

module DbusServices
  module AugeasSerializer

    def augeas_load (path,lense,options={})
      aug = Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => lense, :incl => path)
      aug.load
      augeas_to_hash(aug,"/files#{path}")
    end

    private
      def augeas_to_hash ( aug,path )
        reduction_func = Proc.new do |res,path|
          item = path.split("/").last
          if match = /^(.+)\[(\d+)\]$/.match(item)
            res[match[1]] ||= []
            res[match[1]][match[2].to_i] = augeas_to_hash(aug,path)
          else
            res[item] = augeas_to_hash(aug,path)
          end
          res
        end
        res = aug.match(path+"/*").reduce({},&reduction_func)
        res = aug.get(path) if res.empty?
        return res
      end

  end
end
