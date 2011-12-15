require 'yaml'

module ConfigAgentService
  module ChrootEnv
    def self.run dir
      rd,wr = IO.pipe
      fork do
        rd.close
        wr.write YAML::dump yield
        wr.close
        exit 0
      end
      wr.close
      result = rd.read
      rd.close
      Process.wait
      return YAML::load result
    end
  end
end
