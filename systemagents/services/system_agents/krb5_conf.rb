require 'dbus_services/file_service'
require 'rubygems'
require 'augeas'

module SystemAgents
  class Krb5Conf < DbusServices::FileService

    # identification of relevant DBUS service
    filename "etc_krb5_conf"


    def read(params)

      aug		= Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Krb5.lns", :incl => "/etc/krb5.conf")
      aug.load

      # possible error: parse_failed
      unless aug.get("/augeas/files/etc/krb5.conf/error").nil?
	aug.close
	return {}
      end

      default_realm	= aug.get("/files/etc/krb5.conf/libdefaults/default_realm")
      default_realm	= "" if default_realm.nil?

      krb5_conf	= {
	"default_realm"	=> default_realm,
      }

      clockskew	= aug.get("/files/etc/krb5.conf/libdefaults/clockskew")
      krb5_conf["clockskew"]	= clockskew unless clockskew.nil?

      realms = aug.match("/files/etc/krb5.conf/realms/realm[*]")
    
      # read data from relevant realm section
      realms.each do |realm_path|
	realm	= aug.get(realm_path)
	if (!realm.nil? && realm == default_realm)
	    # put current realm data into return map
	    aug.match(realm_path + "/*").each do |realm_key_path|
		key	= realm_key_path.split("/").last
		next if key.index("#comment") == 0
		krb5_conf[key]	= aug.get(realm_key_path)
	    end
	    break
	end
      end

      # read data from appdefaults sections (called 'application' by augeas)
      # there could be 'pam' and 'pkinit' subsections
      aug.match("/files/etc/krb5.conf/appdefaults/application/*").each do |sub_path|
	key	= sub_path.split("/").last
	next if key.index("#comment") == 0
	krb5_conf[key]	= aug.get(sub_path)
      end

      aug.close
      return krb5_conf
    end

    def write(params)
      aug		= Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Krb5.lns", :incl => "/etc/krb5.conf")
      aug.load

      # update libdefaults section
      default_realm	= params["default_realm"]
      default_domain	= params["default_domain"]

      aug.set("/files/etc/krb5.conf/libdefaults/default_realm", default_realm) unless default_realm.nil?
      aug.set("/files/etc/krb5.conf/libdefaults/clockskew", params["clockskew"]) unless params["clockskew"].nil?

      # update existing realm section
      realm_save_path		= ""

      realms		= aug.match("/files/etc/krb5.conf/realms/realm[*]")
      realms.each do |realm_path|
	realm	= aug.get(realm_path)
	if (!realm.nil? && realm == default_realm)
	    realm_save_path	= realm_path
	    break
	end
      end

      # ... or create new realm section
      if realm_save_path.empty? && !default_realm.nil?
	realm_save_path	= "/files/etc/krb5.conf/realms/realm[#{realms.size + 1}]"
	aug.set(realm_save_path, default_realm)
      end

      unless realm_save_path.empty?
	unless params["kdc"].nil?
	  aug.set(realm_save_path + "/kdc", params["kdc"])
	  aug.set(realm_save_path + "/admin_server", params["kdc"])
	end
	aug.set(realm_save_path + "/default_domain", default_domain) unless default_domain.nil?
      end

      # write domain_realm section
      unless (default_realm.nil? || default_domain.nil?)
	aug.set("/files/etc/krb5.conf/domain_realm/." + default_domain, default_realm)
      end
# FIXME remove domain_realm  default_realm sections in case DNS is used
# (should this be on agent level?)
            
# FIXME when yast2-kerberos-client wrote ExpertSettings, there was a chance to remove the key

      # write appdefaults/pam section
      ["ticket_lifetime", "renew_lifetime", "forwardable", "proxiable", "minimum_uid",
       "keytab", "ccache_dir", "ccname_template", "mappings", "existing_ticket", "external",
       "validate", "use_shmem", "addressless", "debug", "debug_sensitive", "initial_prompt",
       "subsequent_prompt", "banner"].each do |pam_key|
	  
	aug.set("/files/etc/krb5.conf/appdefaults/application/" + pam_key, params[pam_key]) unless params[pam_key].nil?
      end

      # write appdefaults/pkinit section
      unless unless["trusted_servers"].nil?
	pkinit_exists	= false
	appdefaults	= aug.match("/files/etc/krb5.conf/appdefaults/*")
	appdefaults.each do |sub_path|
	  pkinit_exists	= true if aug.get(sub_path) == "pkinit"
	end
	unless pkinit_exists
	  # create new subsection
	  pkinit_path	= "/files/etc/krb5.conf/appdefaults/application[#{appdefaults.size + 1}]"
	  aug.set(pkinit_path, "pkinit")
	end
	aug.set(pkinit_path + "/trusted_servers", params["trusted_servers"])
      end

      ret	= {
	"success"	=> true
      }
      unless aug.save
	ret["success"]	= false
	ret["message"]	= aug.get("/augeas/files/etc/krb5.conf/error/message")
      end

      aug.close
      return ret
    end
  end
end
