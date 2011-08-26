require 'dbus_clients/script_client'

module ConfigAgent
  class PamConfig < DbusClients::ScriptClient

    # identification of relevant DBUS service
    agent_id "sbin_pam_config"
  end
end
