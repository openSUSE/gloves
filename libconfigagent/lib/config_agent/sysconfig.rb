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

module ConfigAgent
  class Sysconfig <  ConfigAgent::FileAgent

      SYSCONFIG_LENS = "Shellvars.lns"

      def initialize path,params={}
        raise ArgumentError,"Path argument must be absolut path" unless path.start_with? '/'
        @file_path = path
      end

      def read(params)
          ret = {}

          aug = load_augeas(params)

          unless aug.get("/augeas/files#{file}/error").nil?
            #FIXME report it. TODO have universal wrapper for this (augeas serializer)
              aug.close
              return ret
          end

          aug.match("/files#{@file_path}/*").each do |key_path|
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
          ret = {
            "success" => true
          }

          aug = load_augeas(params)

          params.each do |key, value|
              next if key.start_with? "_"   # skip internal keys
              aug.set("/files#{@file_path}/#{key}", value) #shell escape here???
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
          char = string[char_pos_p-1]
          case state
          when :unquote
            if char == "'"
              state = :single_quote
            elsif char == '"'
              state = :double_quote
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
              state = :escape
            else
              result << char
            end
          when :escape
            if ['\\',"\n",'$','`','"'].include? char
              result << char
            else #not special escape
              result << '\\' << char
            end 
            state = :double_quote
          else
            raise "Invalid state. Internal Error"
          end
        end
        raise "invalid string value" if state != :unquote
        return result
      end

  end
end
