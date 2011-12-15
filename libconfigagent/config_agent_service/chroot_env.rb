require 'yaml'

module ConfigAgentService
  module ChrootEnv
    def self.run dir
      rd,wr = IO.pipe
      fork do
        Dir.chroot(dir)
        rd.close
        result = YAML::dump(yield) rescue $!
        result = { "error" => result.message, "backtrace" => result.backtrace } if result.is_a?(Exception)
        wr.write result
        wr.close
        exit 0
      end
      wr.close
      result = YAML::load rd.read
      rd.close
      Process.wait
      return result
    end
  end
end
