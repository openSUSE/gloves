$LOAD_PATH << File.dirname(__FILE__)

require 'krb_conf'
require 'pam_config'

# module for kerberos-client configuration
module KerberosClient

  def self.read(params={})
    krb5_conf	= KrbConf.read({})

    pam_krb5	= PamConfig.execute({ "exec_params" => "-q --krb5" })["stdout"] || ""
    sssd	= PamConfig.execute({ "exec_params" => "-q --sss" })["stdout"] || ""
    unless pam_krb5.empty?
      ignore_unknown	= false
      pam_krb5.split("\n").each do |line|
	if line.index("account") == 0
	    ignore_unknown	= !line.index("ignore_unknown_principals").nil?
	end
      end
      krb5_conf["ignore_unknown"] = ignore_unknown
    end

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
