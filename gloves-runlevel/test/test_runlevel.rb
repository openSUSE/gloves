#--
# Gloves Runlevel Library
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
require "test/unit"
require "glove/runlevel"

class TestRunlevel < Test::Unit::TestCase
  def setup
    runlevel_out        = {
      "stdout"  => "N 3"
    }
    ConfigAgent::ScriptAgent.any_instance.stubs(:run).with(["/sbin/runlevel"]).returns(runlevel_out)
  end

  def test_read_1
    ConfigAgent::Runlevel.any_instance.stubs(:read).returns "1"
    ret = Glove::Runlevel.read({})
    assert_kind_of Hash, ret
    assert_equal "3", ret["current"]
    assert_equal "1", ret["default"]
  end

  def test_read_5
    ConfigAgent::Runlevel.any_instance.stubs(:read).returns "5"
    ret = Glove::Runlevel.read({})
    assert_kind_of Hash, ret
    assert_equal "3", ret["current"]
    assert_equal "5", ret["default"]
  end

end
