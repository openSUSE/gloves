require 'dbus_clients/script_client'

module SystemAgent
  class PamConfig < DbusClients::ScriptClient

    # identification of relevant DBUS service
    filename "usr_sbin_pam_config"
  end
end
