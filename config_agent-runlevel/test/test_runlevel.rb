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
require "rubygems"
require "mocha"
require "test/unit"
require "config_agent/runlevel"
require "config_agent/logger"

TMP_LOGDIR      = File.join(File.dirname(__FILE__),".log")
FileUtils.mkdir_p(TMP_LOGDIR) unless File.exist?(TMP_LOGDIR)
ConfigAgent::Logger::AGENTS_LOGDIR   = TMP_LOGDIR

class TestRunlevel < Test::Unit::TestCase
  def setup
  end

  def test_read_sysvinit
    File.stubs(:directory?).returns(false)
    ret = ConfigAgent::Runlevel.new.read({})
    assert_equal "5", ret
  end

  def test_read_systemd_1
    File.stubs(:directory?).returns(true)
    File.stubs(:readlink).returns("/lib/systemd/system/runlevel1.target")
    ret = ConfigAgent::Runlevel.new.read({})
    assert_equal "1", ret
  end

  def test_read_systemd_graphical
    File.stubs(:directory?).returns(true)
    File.stubs(:readlink).returns("/lib/systemd/system/graphical.target")
    ret = ConfigAgent::Runlevel.new.read({})
    assert_equal "5", ret
  end

  def test_read_systemd_multi
    File.stubs(:directory?).returns(true)
    File.stubs(:readlink).returns("/lib/systemd/system/multi-user.target")
    ret = ConfigAgent::Runlevel.new.read({})
    assert_equal "3", ret
  end

end
