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
require "tmpdir"
require "rubygems"
require "config_agent/susefirewall2"

class TestSusefirewall2 < Test::Unit::TestCase

  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end

  def test_read
    file = ConfigAgent::Susefirewall2.new( :root_dir => @data_dir)
    firewall = file.read({})
    assert_equal "zone:ext", firewall["FW_MASQ_DEV"]
  end

  def test_write
    Dir.mktmpdir do |tmp_dir|
      FileUtils.mkdir_p "#{tmp_dir}/etc/sysconfig/"
      file = ConfigAgent::Susefirewall2.new(:root_dir => tmp_dir)
      params = {
        "FW_MASQ_DEV" => "zone:int",
      }
      ret = file.write params
      assert_equal true, ret["success"], ret.inspect
      assert_equal nil,  ret["message"], ret.inspect
    end
  end
end
