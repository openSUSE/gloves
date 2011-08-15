$LOAD_PATH << File.dirname(__FILE__)

require 'system_agent/krb5_conf'
require 'system_agent/pam_config'

# module for kerberos-client configuration
module KerberosClient

  def self.read(params)
    krb5_conf	= SystemAgent::Krb5Conf.read({})
    # FIXME read /etc/ssh/ssh_config

    pam_krb5	= pam_query("krb5")
    sssd	= pam_query("sss")

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

    ret		= {
	"success"	=> true
    }
    # save config file settings
    krb5_conf	= params["kerberos_client"]
    unless krb5_conf.nil? && krb5_conf.empty?
      ret	= SystemAgent::Krb5Conf.write(krb5_conf)
      return ret unless ret["success"] 
    end

    # no changes in PAM config
    return ret if params["pam_login"].nil? || params["pam_login"].empty?

    # update PAM configuration
    sssd	= params["pam_login"]["sssd"]

    # sssd was set up (from different place)
    if sssd
      # FIXME update sssd.conf file here
      pam_delete("krb5")
    # standard authentication (krb5) is on
    elsif params["pam_login"]["use_kerberos"]
      # combined LDAP+Kerberos setup
      if pam_query("ldap").empty?
	pam_add("krb5")
      else
	pam_add("ldap-account_only")
      end
      pam_add("krb5-ignore_unknown_principals") if params["kerberos_client"]["ignore_unknown"]
    # standard authentication (krb5) is off
    else
      pam_delete("krb5")
      # Kerberos removed from combined LDAP+Kerberos setup
      pam_add("ldap") if pam_query("ldap-account_only")
    end

    return ret
  end

  def self.propose(params)
    ret = {}
    return ret
  end

private
  def self.pam_query(mod)
    return SystemAgent::PamConfig.execute({ "exec_params" => "-q --" + mod })["stdout"] || ""
  end

  def self.pam_add(mod)
    return SystemAgent::PamConfig.execute({ "exec_params" => "-a --" + mod })
  end

  def self.pam_delete(mod)
    return SystemAgent::PamConfig.execute({ "exec_params" => "-d --" + mod })
  end

end
