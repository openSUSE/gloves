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

require 'config_agent/file_agent' # Gloves only
require 'augeas'
require 'shellwords'

module ConfigAgent
    class Sysconfig <  ConfigAgent::FileAgent

        SYSCONFIG_LENS = "Shellvars.lns"
        DEFAULT_QUOTE  = '"'

        def initialize path,params={}
            raise ArgumentError,"Path argument must be absolut path" unless path.start_with? '/'
        
            @file_path = path
            @orig_values = {};

            @aug_tree = open_augeas
        end

        def ConfigAgent.finalize( id)
            @aug_tree.close if @aug_tree
        end

        def read(params)
            if( params[ "_aug_internal"])
                @aug_tree.close
                @aug_tree = params[ "_aug_internal"]
            end

            @aug_tree = load_augeas( @aug_tree)
            ret = prepare_read( raw_read( params));
        end

        def write(params)
            if( params[ "_aug_internal"])
                @aug_tree.close
                @aug_tree = params[ "_aug_internal"]
            end

            @aug_tree = load_augeas( @aug_tree)
            return raw_write( prepare_write( params));
        end

    private

        def open_augeas()
            return Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD);
        end
      
        def load_augeas( aug)
            raise ArgumentError, "An error in arguments, cannot create augeas tree." if @aug_tree.nil?

            aug.transform(:lens => SYSCONFIG_LENS, :incl => @file_path)
            aug.load

            return aug
        end

        # to get correct value it is needed to unescape too
        # @example
        #   VAR_1="a\"b\"c"
        #   VAR_2='a\"b\"c'
        #   echo $VAR_1 ---> a"b"c
        #   echo $VAR_2 ---> a\"b\"c
        #
        # we do just best efford, there is more possible outputs and more shell expansions
        STATES = [ :double_quote, :single_quote, :unquote ]
        def unpack( string)
        # Lets do it iterative, so when something not comform adapt it
        # we use state machine for such task
            state = :unquote
            result = ''
        
            1.upto(string.size) do |char_pos_p|
                char = string[char_pos_p-1].chr
          
                case state
                    when :unquote
                        if char == "'"
                            state = :single_quote
                        elsif char == '"'
                            state = :double_quote
                        elsif char == '\\'
                            state = :escape
                        else
                            result << char
                        end
                    when :single_quote
                        if char == "'"
                            state = :unquote
                        else
                            result << char
                        end
                    when :double_quote
                        if char == '"'
                            state = :unquote
                        elsif char == '\\'
                            state = :escape_double
                        else
                            result << char
                        end
                    when :escape_double
                        if ['\\',"\n",'$','`','"'].include? char
                            result << char
                        else #not special escape
                            result << '\\' << char
                        end 
                        state = :double_quote
                    when :escape
                        result << char
                        state = :unquote
                    else
                        raise "Invalid state. Internal Error"
                    end
                end
            
            raise "invalid string value" if state != :unquote
            
            return result
        end

        def pack( string)
        # cannot use Shellwords::escape - augeas (current version of Shellvars.lns) 
        # cannot process escaped space.
        #
        # in fact following simple substitution should be enough
            if string.match( /[ ]/) != nil
                result = "\"#{string.gsub(/\\\"/n, "\"").gsub(/(["])/n, "\\\\\\1")}\"" 
            else
                result = Shellwords.escape( string)
            end        
            
            return result
        end

        # returns content of underlying file as it get it.
        def raw_read(params)
            ret = {}

            unless @aug_tree.get("/augeas/files#{@file_path}/error").nil?
            #FIXME report it. TODO have universal wrapper for this (augeas serializer)
                return ret
            end

            @aug_tree.match("/files#{@file_path}/*").each do |key_path|
                key = key_path.split("/").last
  
                # do not ignore comments, there are several bugs on YaST2 (e.g. comments got lost, ...)
                # TODO: configurable option?
                #      next if key.start_with? "#comment"

                ret[ key] = @aug_tree.get(key_path)
            end

            return ret
        end

        # writes values as it gets them
        def raw_write(params)
            ret = {
                "success" => true
            }

            params.each do |key, value|
                @aug_tree.set("/files#{@file_path}/#{key}", value)
            end

            unless aug.save
                ret["success"] = false
                ret["message"] = @aug_tree.get("/augeas/files#{@file_path}/error/message")
            end

            return ret
        end

        # parse values loaded from the underlying file. It removes quoting and so on.
        def prepare_read( values)
            ret = {}

            values.each do |key, value|
                @orig_values[ key] = value;
              
                # remove quotes from value (Shellvars.lns keeps quoting), unescape values
                #do not unpack comments
                ret[key] = key.start_with?("#comment") ? value : unpack(value)
            end

            return ret
        end
      
        # see prepare_read. Prepare given values into a raw state ready for writing.
        def prepare_write( values)
            ret = {}

            return {} if values.nil?

            values.each do |key, value|
                next if key.start_with? "_"                   # skip internal keys

                if ( !@orig_values[ key].nil? && unpack( @orig_values[ key]) == value)
                    ret[ key] = @orig_values[ key]
                elsif ( key.start_with? "#comment")
                    ret[ key] = value;
                else
                    ret[ key] = pack( value);

	            if !( ret[ key] =~ /^["'].*["']$/)
                        ret[ key] = DEFAULT_QUOTE + ret[ key] + DEFAULT_QUOTE;
		    end 
                end
            end

            return ret
        end

    end     # class
end
