$LOAD_PATH << File.dirname(__FILE__)

require 'system_agent/krb5_conf'
require 'system_agent/pam_config'

# module for kerberos-client configuration
module KerberosClient

  def self.last_error
    return @error
  end

  def self.read(params)
    # read config files    
    begin
      krb5_conf	= SystemAgent::Krb5Conf.read({})
    # FIXME read /etc/ssh/ssh_config

      pam_krb5	= pam_query("krb5")
      sssd	= pam_query("sss")

    rescue DbusClients::InsufficientPermission => e
      @error	= "User has no permission for action '#{e.permission}'."
      return nil
    end
    unless pam_krb5.empty?
      krb5_conf["ignore_unknown"] = pam_krb5.split("\n").any? do |line|
        line.start_with?("account") and line.include? "ignore_unknown_principals"
      end
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
      begin
	ret	= SystemAgent::Krb5Conf.write(krb5_conf)
      rescue DbusClients::InsufficientPermission => e
	@error	= "User has no permission for action '#{e.permission}'."
	return nil
      end
      return ret unless ret["success"] 
    end

    # no changes in PAM config
    return ret if params["pam_login"].nil? || params["pam_login"].empty?

    # update PAM configuration
    sssd	= params["pam_login"]["sssd"]

    # sssd was set up (from different place)
    if sssd
      pam_delete("krb5")
      # FIXME update sssd.conf file here
#              path domain     = add (.etc.sssd_conf.v, "domain/default");
#              SCR::Write (add (domain, "auth_provider"), "krb5");
#              SCR::Write (add (domain, "chpass_provider"), "krb5");
#              SCR::Write (add (domain, "krb5_realm"), default_realm);
#              SCR::Write (add (domain, "krb5_kdcip"), kdc);
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
    # FIXME write pam_pkcs11.conf
    # FIXME write /etc/ssh/ssh_config

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
