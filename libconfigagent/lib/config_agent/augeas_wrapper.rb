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
#
require 'config_agent/file_agent'
require 'augeas'

module ConfigAgent

  class AugeasWrapper < ConfigAgent::FileAgent
    #
    # known params:
    # * lens     - which lens should be used
    # * path     - which file should be loaded
    # * include  - where to look for lenses additionaly to default path
    # * root_dir - which dir should be used as filesystem root
    #
    def initialize( params)

      @incl_path = params[ :include]
      @root_dir  = params[ :root_dir]

      # TODO: add other checks here

      @aug_tree = open_augeas
    end

    def AugeasWrapper.finalize( id)
      @aug_tree.close if @aug_tree
    end

    def read(params)
      #default behavior of read is to provide augeas tree, feel free to overwrite it in subclass
      serialize params
    end

    def write(params)
      deserialize params
    end

protected
    # loads data from the augeas tree and stores them in a hash
    def serialize( params)
      raise ArgumentError, "_aug_internal not supported" if params.has_key?( "_aug_internal")

      aug = load_augeas( @aug_tree)

      #FIXME report it.
      return Hash.new unless aug.get("/augeas/files#{self.class::FILE_PATH}/error").nil?
      return aug_tree_to_hash aug, "/files/"+self.class::FILE_PATH
    end

    def aug_tree_to_hash aug,path
      reduction_func = Proc.new do |res,path|
        item = path.split("/").last
        # do not ignore comments, there are several bugs on YaST2 (e.g. comments got lost, ...)
        # TODO: configurable option?
        #      next if item.start_with? "#comment"
        if match = /^(.+)\[(\d+)\]$/.match(item)
          res[match[1]] ||= []
          res[match[1]][match[2].to_i] = aug_tree_to_hash(aug,path)
        else
          res[item] = aug_tree_to_hash(aug,path)
        end
        res
      end
      res = aug.match(path+"/*").reduce({},&reduction_func)
      res = aug.get(path) if res.empty?
      return res
    end

    # loads data from given hash and stores them in the augeas tree
    def deserialize( params)
      raise ArgumentError, "_aug_internal not supported" if params.has_key?( "_aug_internal")

      ret = {
        "success" => true
      }

      aug = load_augeas( @aug_tree)
      file_path = self.class::FILE_PATH
      params.each do |key, value|
          aug.set("/files#{file_path}/#{key}", value)
      end

      unless aug.save
        ret["success"] = false
        ret["message"] = aug.get("/augeas/files#{file_path}/error/message")
      end

      return ret
    end

  private

    # opens connection to augeas
    def open_augeas()
      aug = Augeas::open(@root_dir, @incl_path, Augeas::NO_MODL_AUTOLOAD)

      aug.transform(:lens => self.class::LENS, :incl => self.class::FILE_PATH)

      return aug
    end
      
    # read the connected file and convert it into augeas tree
    def load_augeas( aug)
      raise ArgumentError, "An error in arguments, cannot create augeas tree." if aug.nil?

      aug.load

      return aug
    end

  end

end
