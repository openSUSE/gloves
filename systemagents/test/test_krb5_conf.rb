$LOAD_PATH << File.join(File.dirname(__FILE__),'..','services')
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "system_agents/krb5_conf"

class TestKrb5Conf < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end

  def test_reading
    file = SystemAgents::Krb5Conf.new nil
    ret = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "example.cz", ret["default_domain"]
  end
end

Test::Unit::UI::Console::TestRunner.run(TestKrb5Conf)
