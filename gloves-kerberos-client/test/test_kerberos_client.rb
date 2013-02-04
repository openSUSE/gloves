#--
# Gloves Kerberos Client Library
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
require "test/unit"
require "glove/kerberos_client"

class TestKerberosClient < Test::Unit::TestCase
  def setup
    krb5_conf_data = {
      "minimum_uid"=>"1",
      "default_domain"=>"example.cz",
      "forwardable"=>"true",
      "clockskew"=>"300",
      "renew_lifetime"=>"1d",
      "proxiable"=>"false",
      "external"=>"sshd",
      "retain_after_close"=>"false",
      "default_realm"=>"EXAMPLE.CZ",
      "use_shmem"=>"sshd",
      "kdc"=>"kdc.example.cz",
      "admin_server"=>"kdc.example.cz",
      "ticket_lifetime"=>"1d"
    }
    ConfigAgent::Krb5Conf.any_instance.stubs(:read).returns krb5_conf_data
    sss_pam_module_out = {
      "stderr" => "",
      "stdout" => "",
      "exitstatus" => 0
    }
    ConfigAgent::ScriptAgent.any_instance.stubs(:run).with(["/usr/sbin/pam-config","-q", "--sss"]).returns(sss_pam_module_out)
    ConfigAgent::SshConfig.any_instance.stubs(:read).returns({"Host" => []})
  end

  def test_read_common
    krb5_pam_module_out = {
      "stderr" => "",
      "stdout" => "auth:\naccount: ignore_unknown_principals\npassword:\nsession:\n",
      "exitstatus" => 0
    }
    ConfigAgent::ScriptAgent.any_instance.stubs(:run).with(["/usr/sbin/pam-config","-q", "--krb5"]).returns(krb5_pam_module_out)
    ret = Glove::KerberosClient.read({})
    assert_equal "300",ret["kerberos_client"]["clockskew"]
    assert_equal true,ret["kerberos_client"]["ignore_unknown"]
    assert_equal true,ret["pam_login"]["use_kerberos"]
    assert_equal false,ret["pam_login"]["sssd"]
  end

  # pam_krb not configured, ignore_unknown not set
  def test_read_not_configured

    krb5_pam_module_out = {
      "stderr" => "",
      "stdout" => "",
      "exitstatus" => 0
    }
    ConfigAgent::ScriptAgent.any_instance.stubs(:run).with(["/usr/sbin/pam-config","-q", "--krb5"]).returns(krb5_pam_module_out)

    ret = Glove::KerberosClient.read({})
    assert_equal false,ret["pam_login"]["use_kerberos"]
    assert_equal nil,ret["kerberos_client"]["ignore_unknown"]
  end

  # pam_krb configured, ignore_unknown is false
  def test_read_without_ignore_unknown

    krb5_pam_module_out = {
      "stderr" => "",
      "stdout" => "auth:\naccount:\npassword:\nsession:\n",
      "exitstatus" => 0
    }
    ConfigAgent::ScriptAgent.any_instance.stubs(:run).with(["/usr/sbin/pam-config","-q", "--krb5"]).returns(krb5_pam_module_out)

    ret = Glove::KerberosClient.read({})
    assert_equal true,ret["pam_login"]["use_kerberos"]
    assert_equal false,ret["kerberos_client"]["ignore_unknown"]
  end

end
