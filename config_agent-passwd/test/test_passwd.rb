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
require "augeas"
require "file/passwd"

class TestPasswd < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end

  def test_reading
    file = Passwd.new
    ret = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "25", ret["at"]["gid"]
    assert_equal "hh", ret["hh"]["name"]
  end

end

Test::Unit::UI::Console::TestRunner.run(TestPasswd)
