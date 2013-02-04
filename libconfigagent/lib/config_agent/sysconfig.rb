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

require 'config_agent/augeas_wrapper'
require 'shellwords'

module ConfigAgent
  class Sysconfig <  AugeasWrapper

    LENS = "Shellvars.lns"
    DEFAULT_QUOTE  = '"'

    def initialize( params = {})
      super( params);

      @orig_values = {};
    end

    def get(params)
      ret = prepare_read( serialize( params));
    end

    def put(params)
      return deserialize( prepare_write( params));
    end

  private

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

  end

end
