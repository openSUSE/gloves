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
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "rubygems"
require "config_agent/augeas_wrapper"

#test augeas wrapper
class Passwd < ConfigAgent::AugeasWrapper
  LENS = "Passwd.lns"
  FILE_PATH = "/etc/passwd"
end


class TestAugeasWrapper < Test::Unit::TestCase

  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end

  def test_default_read
    file = Passwd.new :root_dir => @data_dir
    ret = file.read({})
    assert_equal "25", ret["at"]["gid"]
    assert_equal "hh", ret["hh"]["name"]
  end

  def test_default_write
    file = Passwd.new :root_dir => @data_dir
    ret = file.read({})
    ret["at"]["gid"] = "25"
    ret["new_user"] = { "shell"=>"/bin/false", "password"=>"", "home"=>"/var/lib/test", "gid"=>"1", "name"=>"new_user", "uid"=>"150"}
    file.write ret
    test_ret = file.read({})
    assert_equal ret,test_ret
  end
end

Test::Unit::UI::Console::TestRunner.run(TestAugeasWrapper)
