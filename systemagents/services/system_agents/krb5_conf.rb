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

      default_realm	= aug.get("/files/etc/krb5.conf/libdefaults/default_realm")
      default_realm	= "" if default_realm.nil?

      krb5_conf	= {
	"default_realm"	=> default_realm,
      }

      clockskew	= aug.get("/files/etc/krb5.conf/libdefaults/clockskew")
      krb5_conf["clockskew"]	= clockskew unless clockskew.nil?

      realms = aug.match("/files/etc/krb5.conf/realms/realm[*]")
    
      puts "found realms: #{realms.inspect}"

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

      # read data from appdefaults/pam section (called 'application' by augeas)
      unless aug.get("/files/etc/krb5.conf/appdefaults/application").nil?
	aug.match("/files/etc/krb5.conf/appdefaults/application/*").each do |pam_path|
	    key	= pam_path.split("/").last
	    next if key.index("#comment") == 0
	    krb5_conf[key]	= aug.get(pam_path)
	end
      end

      # FIXME read/write trusted_servers

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
      
      # write appdefaults/pam section
      ["ticket_lifetime", "renew_lifetime", "forwardable", "proxiable", "minimum_uid",
       "keytab", "ccache_dir", "ccname_template", "mappings", "existing_ticket", "external",
       "validate", "use_shmem", "addressless", "debug", "debug_sensitive", "initial_prompt",
       "subsequent_prompt", "banner"].each do |pam_key|
	  
	aug.set("/files/etc/krb5.conf/appdefaults/application/" + pam_key, params[pam_key]) unless params[pam_key].nil?
      end

      ret	= {
	"success"	=> true
      }
      unless aug.save
	puts "saving /etc/krb5.conf failed"
	ret["success"]	= false
	ret["message"]	= aug.get("/augeas/files/etc/krb5.conf/error/message")
      end

      aug.close
      return ret
    end
  end
end
