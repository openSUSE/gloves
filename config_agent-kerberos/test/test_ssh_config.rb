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
require "config_agent/ssh_config"

class TestSshConfig < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
    @data2_dir = File.join(File.dirname(__FILE__),"data2")
  end

  def test_reading
    file = ConfigAgent::SshConfig.new
    ret = file.read "_aug_internal" => Augeas::open(@data_dir, File.join(File.dirname(__FILE__),'..',"lens"),Augeas::NO_MODL_AUTOLOAD)
    hosts	= ret["Host"]
    assert_equal ["LC_IDENTIFICATION", "LC_ALL"], hosts[0]["SendEnv[1]"]
    assert_equal "suse.cz", hosts[0]["Host"]
    assert_equal "*", hosts[1]["Host"]
    assert_equal ["LC_LANG"], hosts[1]["SendEnv"]
  end

  # change the values of GSSAPI keys of suse.cz section
  def test_overwrite

    file2 = ConfigAgent::SshConfig.new
    params	= {
	"_aug_internal"	=> Augeas::open(@data2_dir,File.join(File.dirname(__FILE__),'..',"lens"), Augeas::NO_MODL_AUTOLOAD),
	"Host"	=> [
		{
		    "GSSAPIAuthentication"=>"yes",
		    "GSSAPIDelegateCredentials"=>"yes",
		    "Host"=>"suse.cz",
		    "SendEnv"	=> ["LC_ALL", "LC_LANG"],
		}
	]
    }
    ret = file2.write params
    assert_equal nil, ret["message"]
    assert_equal true, ret["success"]
  end

end
