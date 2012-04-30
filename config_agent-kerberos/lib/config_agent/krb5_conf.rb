#--
# Config Agents Framework
#
# Copyright (C) 2011 Novell, Inc.
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 or version 3 of the GNU Lesser General Public
# License as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require 'config_agent/file_agent'
require "augeas"

module ConfigAgent
  class Krb5Conf < ConfigAgent::FileAgent
    def read(params)

      aug		= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Krb5.lns", :incl => "/etc/krb5.conf")
      aug.load

      # possible error: parse_failed
      # FIXME use exception!
      unless aug.get("/augeas/files/etc/krb5.conf/error").nil?
        aug.close
        return {}
      end

      default_realm	= aug.get("/files/etc/krb5.conf/libdefaults/default_realm")
      default_realm	||= ""

      krb5_conf	= {
        "default_realm"	=> default_realm,
      }

      clockskew	= aug.get("/files/etc/krb5.conf/libdefaults/clockskew")
      krb5_conf["clockskew"]	= clockskew unless clockskew.nil?

      realms = aug.match("/files/etc/krb5.conf/realms/realm[*]")

      # read data from relevant realm section
      realms.each do |realm_path|
        realm	= aug.get(realm_path)
        next if realm != default_realm
        # put current realm data into return map
        aug.match(realm_path + "/*").each do |realm_key_path|
            key	= realm_key_path.split("/").last
            next if key.start_with? "#comment"
            krb5_conf[key]	= aug.get(realm_key_path)
        end
        break
      end

      # read data from appdefaults sections (called 'application' by augeas)
      # there could be 'pam' and 'pkinit' subsections
      aug.match("/files/etc/krb5.conf/appdefaults/application/*").each do |sub_path|
        key	= sub_path.split("/").last
        next if key.start_with? "#comment"
        krb5_conf[key]	= aug.get(sub_path)
      end

      aug.close
      return krb5_conf
    end

    def write(params)
      aug		= params["_aug_internal"] || Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => "Krb5.lns", :incl => "/etc/krb5.conf")
      aug.load

      # update libdefaults section
      default_realm	= params["default_realm"]

      aug.set("/files/etc/krb5.conf/libdefaults/default_realm", default_realm) if default_realm
      aug.set("/files/etc/krb5.conf/libdefaults/clockskew", params["clockskew"]) if params["clockskew"]

      # update existing realm section
      realm_save_path		= ""

      realms		= aug.match("/files/etc/krb5.conf/realms/*")
      realm_save_path = realms.detect { |realm_path| aug.get(realm_path) == default_realm }
      realm_save_path ||= ""

      # ... or create new realm section
      if realm_save_path.empty? && default_realm
        realm_save_path	= "/files/etc/krb5.conf/realms/realm[#{realms.size + 1}]"
        aug.set(realm_save_path, default_realm)
      end

      default_domain	= params["default_domain"]
      unless realm_save_path.empty?
        if params["kdc"]
          aug.set(realm_save_path + "/kdc", params["kdc"])
          aug.set(realm_save_path + "/admin_server", params["kdc"])
        end
        aug.set(realm_save_path + "/default_domain", default_domain) unless default_domain.nil?
      end

      # write domain_realm section
      if default_realm && default_domain
        aug.set("/files/etc/krb5.conf/domain_realm/." + default_domain, default_realm)
      end
      # FIXME remove domain_realm  default_realm sections in case DNS is used
      # (should this be on agent level?)

      write_pam aug, params
      write_trusted_servers aug, params

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

  private
    # write appdefaults/pkinit section
    def write_trusted_servers aug, params
      return unless params["trusted_servers"]
      appdefaults	= aug.match("/files/etc/krb5.conf/appdefaults/*")
      pkinit_exists = appdefaults.any? {|sub_path| aug.get(sub_path) == "pkinit" }
      pkinit_path	= "/files/etc/krb5.conf/appdefaults/application"
      unless pkinit_exists
        # create new subsection
        pkinit_path	= "/files/etc/krb5.conf/appdefaults/application[#{appdefaults.size + 1}]"
        aug.set(pkinit_path, "pkinit")
      end
      aug.set(pkinit_path + "/trusted_servers", params["trusted_servers"])
    end

    # write appdefaults/pam section
    def write_pam aug, params
      appdefaults	= aug.match("/files/etc/krb5.conf/appdefaults/*")
      pam_exists = appdefaults.any? {|sub_path| aug.get(sub_path) == "pam" }
      pam_path	= "/files/etc/krb5.conf/appdefaults/application"

      ["ticket_lifetime", "renew_lifetime", "forwardable", "proxiable", "minimum_uid",
       "keytab", "ccache_dir", "ccname_template", "mappings", "existing_ticket", "external",
       "validate", "use_shmem", "addressless", "debug", "debug_sensitive", "initial_prompt",
       "subsequent_prompt", "banner"].each do |pam_key|
        if params.has_key? pam_key
          unless pam_exists
            pam_path	= "/files/etc/krb5.conf/appdefaults/application[#{appdefaults.size + 1}]"
            aug.set(pam_path, "pam")
            pam_exists	= true
          end
          if params[pam_key].nil? || params[pam_key].empty?
            aug.rm(pam_path + "/" + pam_key)
          else
            aug.set(pam_path + "/" + pam_key, params[pam_key])
          end
        end
      end
    end
  end
end
