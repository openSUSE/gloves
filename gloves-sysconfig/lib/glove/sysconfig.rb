#--
# Gloves Sysconfig Library
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

$LOAD_PATH << File.dirname(__FILE__)

require 'config_agent/sysconfig'

# module for users configuration
module Glove

  module Sysconfig

    def self.last_error
      return @error
    end

    # Read all settings relevant for Users configuration
    # Standard Gloves way
    def self.read(params)
      ret       = {}

      begin
        ret     = ConfigAgent::Sysconfig.read(params)
      rescue DbusClients::InsufficientPermission => e
        @error	= "User has no permission for action '#{e.permission}'."
        return nil
      end
      return ret;
    end

    def self.write( params)
        ret = {}

        ret = ConfigAgent::Sysconfig.write( params)

        return ret
    end

private

  end
end
