$:.unshift(File::join("../../..", "dbus-infrastructure"))

require 'dbus_services/file_service'
require 'rubygems'
require 'augeas'

module SystemAgents
  class KrbConf < DbusServices::FileService

    # identification of relevant DBUS service
    filename "_etc_krb5_conf"

    def read(params)

      kdc		= ""
      default_domain	= ""
      default_realm	= ""

      aug			= Augeas::open

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

      aug.close
      return krb5_conf
    end

    def write(params)

      aug			= Augeas::open

      # update libdefaults section
      default_realm	= params["default_realm"]
      default_domain	= params["default_domain"]
      kdc		= params["kdc"]

      aug.set("/files/etc/krb5.conf/libdefaults/default_realm", default_realm) unless default_realm.nil?

      # update existing realm section
      save_path		= ""

      realms		= aug.match("/files/etc/krb5.conf/realms/realm[*]")
      realms.each do |realm_path|
	realm	= aug.get(realm_path)
	if (!realm.nil? && realm == default_realm)
	    save_path	= realm_path
	    break
	end
      end
      puts "----------- save path: #{save_path}"

      # ... or create new realm section
      if save_path.empty?
	save_path	= "/files/etc/krb5.conf/realms/realm[#{realms.size + 1}]"
	aug.set(save_path, default_realm)
      end

      aug.set(save_path + "/kdc", kdc)
      aug.set(save_path + "/admin_server", kdc)
      aug.set(save_path + "/default_domain", default_domain)

      # FIXME write domain_realm, libdefaults and appdefaults sections

      ret	= {
	"success"	=> true
      }
      unless aug.save
	puts "saving /etc/krb5.conf failed"
	ret["success"]	= false
      end

      aug.close
      return ret
    end

  end
end
