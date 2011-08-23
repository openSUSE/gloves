$LOAD_PATH << File.join(File.dirname(__FILE__),'..','services')
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "system_agents/ssh_config"

class TestSshConfig < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end
end

Test::Unit::UI::Console::TestRunner.run(TestSshConfig)
