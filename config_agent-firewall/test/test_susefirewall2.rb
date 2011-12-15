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
require "file/susefirewall2"

class TestSusefirewall2 < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
  end

  def test_read
    file = Susefirewall2.new
    firewall = file.read "_aug_internal" => Augeas::open(@data_dir, File.join(File.dirname(__FILE__),'..',"lens"),Augeas::NO_MODL_AUTOLOAD)
    assert_equal "zone:ext", firewall["FW_MASQ_DEV"]
  end

  def test_write
    file = Susefirewall2.new
    params = {
      "_aug_internal" => Augeas::open(@data1_dir,nil, Augeas::NO_MODL_AUTOLOAD),
      "FW_MASQ_DEV" => "zone:int",
    }
    ret = file.write params
    assert_equal true, ret["success"], ret.inspect
    assert_equal nil,  ret["message"], ret.inspect
  end
end

Test::Unit::UI::Console::TestRunner.run(TestSusefirewall2)
