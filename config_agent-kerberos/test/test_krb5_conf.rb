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
require "config_agent/krb5_conf"

class TestKrb5Conf < Test::Unit::TestCase
  def setup
    @data_dir = File.join(File.dirname(__FILE__),"data")
    @data1_dir = File.join(File.dirname(__FILE__),"data1")
    @data2_dir = File.join(File.dirname(__FILE__),"data2")
  end

  def test_reading
    file = ConfigAgent::Krb5Conf.new
    ret = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "example.cz", ret["default_domain"]
    assert_equal "kdc.example.cz", ret["kdc"]
    assert_equal "1d", ret["ticket_lifetime"]
    assert_equal "ad.example.cz", ret["trusted_servers"]
  end

  # write new file
  def test_write
    file = ConfigAgent::Krb5Conf.new
    params	= {
	"_aug_internal" => Augeas::open(@data1_dir,nil, Augeas::NO_MODL_AUTOLOAD),
	"default_domain"	=> "example.de",
	"default_realm"		=> "EXAMPLE.DE",
	"kdc"			=> "kdc.example.de", # sets also admin_server
	"trusted_servers"	=> "ad.example.de",
	"proxiable"		=> "true"
    }
    ret = file.write params
    assert_equal true, ret["success"]
    assert_equal nil, ret["message"]
  end

  # diff data/etc/krb5.conf data2/etc/krb5.conf -> change value of kdc, remove ticket_lifetime
  def test_overwrite
    file = ConfigAgent::Krb5Conf.new
    params = file.read "_aug_internal" => Augeas::open(@data_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    assert_equal "1d", params["ticket_lifetime"]

    file2 = ConfigAgent::Krb5Conf.new
    params["_aug_internal"]	= Augeas::open(@data2_dir,nil, Augeas::NO_MODL_AUTOLOAD)
    params["kdc"]		= "kdc.example.de"
    params["ticket_lifetime"]	= ""
    params["proxiable"]		= nil

    ret = file2.write params
    assert_equal nil, ret["message"]
  end

end
