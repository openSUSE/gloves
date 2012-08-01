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

$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
$LOAD_PATH.unshift File.dirname(__FILE__)
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "rubygems"
require "config_agent/adjtime"

class TestAdjtime < Test::Unit::TestCase
  LENSES_DIR = File.join(File.dirname(__FILE__),'..','lens')

  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
    @data1_dir = File.join(File.dirname(__FILE__),"data1")
    @data2_dir = File.join(File.dirname(__FILE__),"data2")
  end

  def test_no_file
    file = ConfigAgent::Adjtime.new
    adjtime = file.read "_aug_internal" => Augeas::open(@data_dir + "/tmp", LENSES_DIR, Augeas::NO_MODL_AUTOLOAD)
    assert_equal Hash.new, adjtime
  end

  def test_reading
    file = ConfigAgent::Adjtime.new
    adjtime = file.read "_aug_internal" => Augeas::open(@data_dir, LENSES_DIR, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "LOCAL", adjtime["3"]
  end

  # write new file
  def test_write
    file = ConfigAgent::Adjtime.new
    params	= {
      "_aug_internal"   => Augeas::open(@data1_dir, LENSES_DIR, Augeas::NO_MODL_AUTOLOAD),
      "3" => "UTC",
      "2" => "0",
      "1" => "0.0 0 0.0"
    }
    ret = file.write params
    assert_equal true, ret["success"]
    assert_equal nil, ret["message"]
  end

  # diff data/etc/adjtime data2/etc/adjtime -> change LOCAL to UTC
  def test_overwrite
    file = ConfigAgent::Adjtime.new
    params = file.read "_aug_internal" => Augeas::open(@data_dir, LENSES_DIR, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "LOCAL", params["3"]

    file2 = ConfigAgent::Adjtime.new
    params["_aug_internal"]	= Augeas::open(@data2_dir, LENSES_DIR, Augeas::NO_MODL_AUTOLOAD)
    params["3"]   = "UTC"

    ret = file2.write params
    assert_equal nil, ret["message"]
  end


end

Test::Unit::UI::Console::TestRunner.run(TestAdjtime)
