$LOAD_PATH << File.dirname(__FILE__)

require 'krb_conf'
require 'pam_config'

# module for kerberos-client configuration
module KerberosClient

  def self.read(params={})
    krb5_conf	= KrbConf.read({})

    pam_krb5	= PamConfig.execute({ "exec_params" => "-q --krb5" })["stdout"] || ""
    sssd	= PamConfig.execute({ "exec_params" => "-q --sss" })["stdout"] || ""

    # returning same structure as Kerberos::Export
    return {
      "pam_login"		=> {
	    "use_kerberos"	=> !pam_krb5.empty?,
  	    "sssd"		=> !sssd.empty?,
      },
      "kerberos_client"		=> krb5_conf
    }
  end

  def self.write(params)
    ret = {}
    return ret
  end

  def self.propose(params)
    ret = {}
    return ret
  end
end
