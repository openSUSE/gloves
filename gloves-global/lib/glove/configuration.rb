#--
# Gloves Global module
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

require "singleton"
require "glove/chroot_env"
require "config_agent/file_agent"
require "config_agent/script_agent"

module Glove
  class Configuration
    include Singleton
    attr_accessor :chroot

    def agent_parameters
      ret = {}
      ret["__chroot"] = chroot if chroot
      return ret
    end
  end
end

#reopen config_agents so all gloves lib implicitelly use agent parameters
module ConfigAgent
  module FileAgent
    # if it start increasing lets add hooks to agents
    alias_method :gloves_conf_extended_read, :read
    def read params
      chroot_dir = Glove::Configuration.instance.chroot
      if chroot_dir
        Glove::ChrootEnv.run(chroot_dir) do
          gloves_conf_extended_read params
        end
      else
        #first what we do is chrooting
        gloves_conf_extended_read params
      end
    end

    alias_method :gloves_conf_extended_write, :write
    def write params
      chroot_dir = Glove::Configuration.instance.chroot
      if chroot_dir
        Glove::ChrootEnv.run(chroot_dir) do
          gloves_conf_extended_write params
        end
      else
        #first what we do is chrooting
        gloves_conf_extended_write params
      end
    end
  end
end

module ConfigAgent
  module ScriptAgent
    # if it start increasing lets add hooks to agents
    alias_method :gloves_conf_extended_call, :call
    def call params
      chroot_dir = Glove::Configuration.instance.chroot
      if chroot_dir
        Glove::ChrootEnv.run(chroot_dir) do
          gloves_conf_extended_call params
        end
      else
        #first what we do is chrooting
        gloves_conf_extended_call params
      end
    end
  end
end


