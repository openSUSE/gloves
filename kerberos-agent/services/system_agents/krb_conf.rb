$:.unshift(File::join("../../..", "dbus-infrastructure"))

require 'file_service.rb'
require 'rubygems'
require 'augeas'

module SystemAgents
  class KrbConf < FileService

    # identification of relevant DBUS service
    filename "_etc_krb5_conf"

    def read(params)

      kdc		= ""
      default_domain	= ""
      default_realm	= ""

      aug			= Augeas::open

      default_realm	= aug.get("/files/etc/krb5.conf/libdefaults/default_realm")
      default_realm	= "" if default_realm.nil?

      realms = aug.match("/files/etc/krb5.conf/realms/realm[*]")
    
      puts "found realms: #{realms.inspect}"

      realms.each do |realm_path|
	realm	= aug.get(realm_path)
	if (!realm.nil? && realm == default_realm)
	    kdc			= aug.get(realm_path + "/kdc")
	    default_domain	= aug.get(realm_path + "/default_domain")
	    break
	end
      end

      kdc		= "" if kdc.nil?
      default_domain	= "" if default_domain.nil?

      kerberos	= {
	"kdc"		=> kdc,
	"default_realm"	=> default_realm,
	"default_domain"=> default_domain,
      }

      aug.close
      return kerberos
    end

    def write(params)

      aug			= Augeas::open

      # update libdefaults section
      default_realm	= params["default_realm"]
      default_domain	= params["default_domain"]
      kdc		= params["kdc"]

      aug.set("/files/etc/krb5.conf/libdefaults/default_realm", default_realm) unless default_realm.nil?

      # update realm section
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

      # create new section
      if save_path.empty?
	save_path	= "/files/etc/krb5.conf/realms/realm[#{realms.size + 1}]"
	aug.set(save_path, default_realm)
      end

      aug.set(save_path + "/kdc", kdc)
      aug.set(save_path + "/admin_server", kdc)
      aug.set(save_path + "/default_domain", default_domain)

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
