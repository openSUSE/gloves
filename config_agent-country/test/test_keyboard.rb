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

$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','services')
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "rubygems"
require "config_agent_service/keyboard"

class TestKeyboard < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
    @data1_dir = File.join(File.dirname(__FILE__),"data1")
    @data2_dir = File.join(File.dirname(__FILE__),"data2")
  end

  def test_reading
    file = ConfigAgentService::Keyboard.new nil
    sysconfig_keyboard = file.read "_aug_internal" => Augeas::open(@data_dir, File.join(File.dirname(__FILE__),'..',"lens"),Augeas::NO_MODL_AUTOLOAD)
    assert_equal "english-us,pc104", sysconfig_keyboard["YAST_KEYBOARD"]
    assert_equal "us.map.gz", sysconfig_keyboard["KEYTABLE"]
    assert_equal "bios", sysconfig_keyboard["KBD_NUMLOCK"]
    assert_equal "", sysconfig_keyboard["KBD_DELAY"]
  end

  # write new file
  def test_write
    file = ConfigAgentService::Keyboard.new nil
    params	= {
	"_aug_internal"		=> Augeas::open(@data1_dir,nil, Augeas::NO_MODL_AUTOLOAD),
	"YAST_KEYBOARD"		=> "english-uk,pc104",
	"KEYTABLE"		=> "uk.map.gz"
    }
    ret = file.write params
    assert_equal true, ret["success"]
    assert_equal nil, ret["message"]
  end

  # diff data/etc/sysconfig/keyboard data2/etc/sysconfig/keyboard -> change value of RC_LANG
  def test_overwrite
    file = ConfigAgentService::Keyboard.new nil
    params = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "english-us,pc104", params["YAST_KEYBOARD"]
    assert_equal "us.map.gz", params["KEYTABLE"]

    file2 = ConfigAgentService::Keyboard.new nil
    params["_aug_internal"]	= Augeas::open(@data2_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    params["YAST_KEYBOARD"]	= "english-uk,pc104"
    params["KEYTABLE"]		= "uk.map.gz"

    ret = file2.write params
    assert_equal nil, ret["message"]
  end
end

Test::Unit::UI::Console::TestRunner.run(TestKeyboard)
