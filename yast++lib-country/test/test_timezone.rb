#--
# YaST++ Timezone Library
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

$LOAD_PATH << File.join(File.dirname(__FILE__),'..')
require "rubygems"
require "mocha"
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "y_lib/timezone"

class TestTimezone < Test::Unit::TestCase
  def setup
    sysconfig_data = {
      "TIMEZONE" => "Europe/Prague",
      "HWCLOCK" => "--localtime"
    }
    ConfigAgent::Clock.stubs(:read).returns sysconfig_data
  end

  def test_read_sysconfig
    ret = YLib::Timezone.read({})
    assert_equal "Europe/Prague",ret["timezone"]
    assert_equal "--localtime", ret["hwclock"]
  end

  def test_read_timezones
    ret = YLib::Timezone.read({ "kind" => "timezones" })
    assert_kind_of Hash, ret
    assert_kind_of Array, ret["timezones"]
  end

  def test_read_regions_map
    ret = YLib::Timezone.read({ "kind" => "regions" })
    assert_kind_of Hash, ret
    assert_kind_of Hash, ret["Europe"]
    assert_equal "Czech Republic", ret["Europe"]["Europe/Prague"]
  end

  def test_read_region
    ret = YLib::Timezone.read({ "kind" => "regions", "only" => "USA" })
    assert_kind_of Hash, ret
    assert_equal "Eastern (New York)", ret["America/New_York"]
  end

  def test_read_wrong_region
    ret = YLib::Timezone.read({ "kind" => "regions", "only" => "US" })
    assert_kind_of Hash, ret
    assert_equal 0, ret.size
  end

end

Test::Unit::UI::Console::TestRunner.run(TestTimezone)
