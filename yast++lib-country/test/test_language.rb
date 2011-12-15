#--
# YaST++ Language Library
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
require "y_lib/language"

class TestLanguage < Test::Unit::TestCase
  def setup
    sysconfig_data = {
      "RC_LANG" => "cs_CZ.UTF-8",
      "INSTALLED_LANGUAGES" => "cs_CZ,de_DE,en_US"
    }
    ConfigAgent::Language.stubs(:read).returns sysconfig_data
  end

  def test_read_sysconfig
    ret = YLib::Language.read({})
    assert_equal "cs_CZ.UTF-8",ret["language"]
    assert_equal "cs_CZ,de_DE,en_US",ret["languages"]
  end


end

Test::Unit::UI::Console::TestRunner.run(TestLanguage)
