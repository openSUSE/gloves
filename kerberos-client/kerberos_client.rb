$LOAD_PATH << File.dirname(__FILE__)

require 'system_agent/krb5_conf'
require 'system_agent/pam_config'

# module for kerberos-client configuration
module KerberosClient

  def self.read(params)
    krb5_conf	= SystemAgent::Krb5Conf.read({})

    pam_krb5	= SystemAgent::PamConfig.execute({ "exec_params" => "-q --krb5" })["stdout"] || ""
    sssd	= SystemAgent::PamConfig.execute({ "exec_params" => "-q --sss" })["stdout"] || ""
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
    krb5_conf	= params["kerberos_client"]
    krb5_conf	= {} if krb5_conf.nil?
    ret = SystemAgent::Krb5Conf.write(krb5_conf)
    return ret
  end

  def self.propose(params)
    ret = {}
    return ret
  end
end
