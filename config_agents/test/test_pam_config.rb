$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','services')
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "rubygems"
require "config_agent/pam_config"

class TestPamConfig < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end
end

Test::Unit::UI::Console::TestRunner.run(TestPamConfig)
