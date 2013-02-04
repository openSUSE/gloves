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
require "test/unit"
require "rubygems"
require "augeas"
require "config_agent/passwd"

class TestPasswd < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end

  def test_reading
    file = ConfigAgent::Passwd.new
    ret = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "25", ret["at"]["gid"]
    assert_equal "hh", ret["hh"]["name"]
  end

  def test_read_one
    file = ConfigAgent::Passwd.new
    ret = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD), "id" => "hh"
    assert_equal "/home/hh", ret["home"]
    assert_equal "hh", ret["name"]
  end

  def test_read_usernames
    file = ConfigAgent::Passwd.new
    ret = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD), "only" => "login"
    assert_equal 6, ret["result"].size
    assert_equal ["at", "bin", "daemon", "root", "hh", "@nisdefault"], ret["result"]
  end

end
