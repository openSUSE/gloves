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

# Provides chrooting ability
module ChrootEnv
  # Run block in changed root to dir
  # @param [String] dir of new root
  # @yield code that runs in changed root with all limitations
  # @yieldreturn [Object] Returns return value of block with limitation that for serialization is used YAML, so object to serialize must support it.
  # @note exception is transformed into hash with key error and backtrace or specialized hash for BackendException
  def self.run dir
    rd,wr = IO.pipe
    fork do
      Dir.chroot(dir)
      rd.close
      result = yield rescue $!
      wr.write result Marshal.dump(result)
      wr.close
      exit 0
    end
    wr.close
    result = Marshal.load rd.read
    rd.close
    Process.wait
    if result.is_a? Exception
      raise result.class,result.message,result.backtrace #continue with exception
    end
    return result
  end
end
