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

require 'config_agent_service/file_service' # Gloves only
require 'augeas'
require 'lib/SysconfigGlibShell'                # extension / stub to libglib (unquoting)

# TODO: read, write: params[ "file"] should contain absolute path - add check
class Sysconfig < ConfigAgentService::FileService
#class Sysconfig    # YaST2

    SYSCONFIG_LENS = "Shellvars.lns"

    def read(params)
        return {} if !params.has_key?( "file");

        file = params[ "file"];
        ret = {}

        aug = load_augeas(params)

        unless aug.get("/augeas/files#{file}/error").nil?
            aug.close
            return ret
        end

        aug.match("/files#{file}/*").each do |key_path|
            key = key_path.split("/").last
# do not ignore comments, there are several bugs on YaST2 (e.g. comments got lost, ...)
# TODO: configurable option?
#      next if key.start_with? "#comment"

            # remove quotes from value (Shellvars.lns keeps quoting), unescape values
            ret[key] = unpack( aug.get(key_path))
        end

        aug.close

        return ret
    end

    def write(params)
        return { "success" => false, "message" => "Missing desc file" } if !params.has_key?( "file");

        file = params[ "file"];
        ret = {
          "success" => true
        }

        aug = load_augeas(params)

        params.each do |key, value|
            next if key.start_with? "_"   # skip internal keys
            next if key == "file"         # destination flag.
            aug.set("/files#{file}/#{key}", value)
        end

        unless aug.save
            ret["success"] = false
            ret["message"] = aug.get("/augeas/files#{file}/error/message")
        end

        aug.close
        
        return ret
    end

private

    def load_augeas(params)
        aug = params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
        aug.transform(:lens => SYSCONFIG_LENS, :incl => params[ "file"])
        aug.load

        return aug
    end

    def unpack( string)
        # to get correct value it is needed to unescape too
        # Examples:
        # VAR_1="a\"b\"c"
        # VAR_2='a\"b\"c'
        #
        # echo $VAR_1 ---> a"b"c
        # echo $VAR_2 ---> a\"b\"c
        #
# for testing only otherwise danger (does full expansion)
#        return %x( echo #{string})
        return SysconfigGlibShell.unquote( string);
    end

end
