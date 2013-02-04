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
require "config_agent/keyboard"

class TestKeyboard < Test::Unit::TestCase
  LENSES_DIR = File.join(File.dirname(__FILE__),'..','lens')

  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
    @data1_dir = File.join(File.dirname(__FILE__),"data1")
    @data2_dir = File.join(File.dirname(__FILE__),"data2")
  end

  def test_reading
    file = ConfigAgent::Keyboard.new( :root_dir => @data_dir, :include => LENSES_DIR )
    sysconfig_keyboard = file.read({})
    assert_equal "english-us,pc104", sysconfig_keyboard["YAST_KEYBOARD"]
    assert_equal "us.map.gz", sysconfig_keyboard["KEYTABLE"]
    assert_equal "bios", sysconfig_keyboard["KBD_NUMLOCK"]
    assert_equal "", sysconfig_keyboard["KBD_DELAY"]
  end

  # write new file
  def test_write
    file = ConfigAgent::Keyboard.new( :root_dir => @data1_dir, :include => LENSES_DIR )
    params        = {
        "YAST_KEYBOARD"		=> "english-uk,pc104",
        "KEYTABLE"		=> "uk.map.gz"
    }
    ret = file.write params
    assert_equal nil, ret["message"]
    assert_equal true, ret["success"]
  end

  # diff data/etc/sysconfig/keyboard data2/etc/sysconfig/keyboard -> change value of RC_LANG
  def test_overwrite
    file = ConfigAgent::Keyboard.new( :root_dir => @data_dir, :include => LENSES_DIR )
    params = file.read({})
    assert_equal "english-us,pc104", params["YAST_KEYBOARD"]
    assert_equal "us.map.gz", params["KEYTABLE"]

    file2 = ConfigAgent::Keyboard.new( :root_dir => @data2_dir, :include => LENSES_DIR )
    params["YAST_KEYBOARD"]        = "english-uk,pc104"
    params["KEYTABLE"]        	= "uk.map.gz"

    ret = file2.write params
    assert_equal nil, ret["message"]
  end
end
