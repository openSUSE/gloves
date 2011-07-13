require "dbus_clients/script_client"

class PamConfig < DbusClients::ScriptClient
  filename "pam_config"
end
