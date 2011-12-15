require 'yaml'

module ConfigAgentService
  module ChrootEnv
    def self.run dir
      rd,wr = IO.pipe
      fork do
	Dir.chroot(dir)
        rd.close
	result = YAML::dump(yield) rescue $!
        wr.write result
        wr.close
        exit 0
      end
      wr.close
      result = YAML::load rd.read
      rd.close
      Process.wait
      raise result if result.is_a? Exception
      return result
    end
  end
end
