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
require "config_agent/sysconfig"

class TestSysconfig < Test::Unit::TestCase

TEST_QUOTING_MAP = {
  "string" => "string",
  "\"double_quote\"" => "double_quote",
  "'single quote'" => "single quote",
  "quote' 'in\" \"middle" => "quote in middle",
  "\"escaping double \\\" \\\n \'\"" => "escaping double \" \n '",
  "escaping normal \\a\\b\\\" \\c\\d\\n \\'" => "escaping normal ab\" cdn '"
}
  def test_unquoting
    agent = ConfigAgent::Sysconfig.new "/dummy"
    TEST_QUOTING_MAP.each do |test,result|
      assert_equal result,agent.send(:unpack,test)
    end
  end

end

Test::Unit::UI::Console::TestRunner.run(TestSysconfig)
