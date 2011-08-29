$LOAD_PATH << File.dirname(__FILE__)

require 'config_agent/krb5_conf'
require 'config_agent/ssh_config'
require 'config_agent/pam_config'

require 'socket'

# module for kerberos-client configuration
module KerberosClient

  def self.last_error
    return @error
  end

  # Read all settings relevant for Kerberos client configuration
  def self.read(params)
    # read config files    
    begin
      krb5_conf	= ConfigAgent::Krb5Conf.read({})
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

    krb5_conf["ssh_support"]	= read_ssh_support

    # returning same structure as Kerberos::Export
    return {
      "pam_login"		=> {
	    "use_kerberos"	=> !pam_krb5.empty?,
  	    "sssd"		=> !sssd.empty?,
      },
      "kerberos_client"		=> krb5_conf
    }
  end

  # Write Kerberos client configuration
  def self.write(params)

    ret		= {
	"success"	=> true
    }
    # save config file settings
    krb5_conf	= params["kerberos_client"]
    ssh_support	= krb5_conf.delete "ssh_support"
    ignore_unknown	= krb5_conf.delete "ignore_unknown"

    unless krb5_conf.nil? && krb5_conf.empty?
      ret	= ConfigAgent::Krb5Conf.write(krb5_conf)
      return ret unless ret["success"] 
    end

    ret = write_ssh_support(ssh_support) unless ssh_support.nil?

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
      pam_add("krb5-ignore_unknown_principals") if ignore_unknown
    # standard authentication (krb5) is off
    else
      pam_delete("krb5")
      # Kerberos removed from combined LDAP+Kerberos setup
      pam_add("ldap") if pam_query("ldap-account_only")
    end
    # FIXME write pam_pkcs11.conf

    return ret
  rescue DbusClients::InsufficientPermission => e
    @error	= "User has no permission for action '#{e.permission}'."
    return nil
  end

  def self.propose(params)
    ret = {}
    return ret
  end

private
  def self.pam_query(mod)
    return ConfigAgent::PamConfig.execute({ "exec_params" => "-q --" + mod })["stdout"] || ""
  end

  def self.pam_add(mod)
    return ConfigAgent::PamConfig.execute({ "exec_params" => "-a --" + mod })
  end

  def self.pam_delete(mod)
    return ConfigAgent::PamConfig.execute({ "exec_params" => "-d --" + mod })
  end

  # Read state of ssh support from /etc/ssh/ssh_config
  def self.read_ssh_support
    hostname	= Socket.gethostname
    ssh_config	= ConfigAgent::SshConfig.read({})["ssh_config"]
    
    ssh_support	= false
    ssh_config.each do |host|
	if (host["Host"] == "*" || host["Host"] == hostname) &&
	    (host["GSSAPIAuthentication"] && host["GSSAPIDelegateCredentials"])
	    ssh_support	= host["GSSAPIAuthentication"] == "yes" && host["GSSAPIDelegateCredentials"] == "yes"
	    @ssh_section = host["Host"]
	    break
	end
    end
    return ssh_support
  end

  def self.write_ssh_support ssh_support

    # read ssh config to find out if there's matching Host section
    read_ssh_support if @ssh_section.nil?
    @ssh_section = "*" if @ssh_section.nil?
    ssh_value	= ssh_support ? "yes": "no"
    # only update existing section
    ssh_config	= {
	"update"	=> {
	    @ssh_section	=> {
		"GSSAPIAuthentication"	=> ssh_value,
		"GSSAPIDelegateCredentials" => ssh_value
	    }
	}
    }
    ret	= ConfigAgent::SshConfig.write(ssh_config)
    return ret
  end

end
