require 'yaml'

require "config_agent/backend_exception"

module ConfigAgent
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
end
