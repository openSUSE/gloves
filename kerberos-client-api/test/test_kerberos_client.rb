$LOAD_PATH << File.join(File.dirname(__FILE__),'..')
require "rubygems"
require "mocha"
require "test/unit/testcase"
require 'test/unit/ui/console/testrunner'
require "kerberos_client"

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
    SystemAgent::Krb5Conf.stubs(:read).returns krb5_conf_data
    sss_pam_module_out = {
      "stderr" => "",
      "stdout" => "",
      "exitstatus" => 0
    }
    SystemAgent::PamConfig.stubs(:execute).with("exec_params" => "-q --sss" ).returns(sss_pam_module_out)
  end

  def test_read_common
    krb5_pam_module_out = {
      "stderr" => "",
      "stdout" => "auth:\naccount: ignore_unknown_principals\npassword:\nsession:\n",
      "exitstatus" => 0
    }
    SystemAgent::PamConfig.stubs(:execute).with("exec_params" => "-q --krb5" ).returns(krb5_pam_module_out)

    ret = KerberosClient.read({})
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
    SystemAgent::PamConfig.stubs(:execute).with("exec_params" => "-q --krb5" ).returns(krb5_pam_module_out)

    ret = KerberosClient.read({})
    assert_equal false,ret["pam_login"]["use_kerberos"]
    assert_equal nil,ret["kerberos_client"]["ignore_unknown"]
  end

  # pam_krb configured, ignore_unknown is false
  def test_read_withou_ignore_unknown

    krb5_pam_module_out = {
      "stderr" => "",
      "stdout" => "auth:\naccount:\npassword:\nsession:\n",
      "exitstatus" => 0
    }
    SystemAgent::PamConfig.stubs(:execute).with("exec_params" => "-q --krb5" ).returns(krb5_pam_module_out)

    ret = KerberosClient.read({})
    assert_equal true,ret["pam_login"]["use_kerberos"]
    assert_equal false,ret["kerberos_client"]["ignore_unknown"]
  end

end

Test::Unit::UI::Console::TestRunner.run(TestKerberosClient)
