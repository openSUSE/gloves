require "dbus_clients/script_client"

class PamConfig < DbusClients::FileClient
  filename "pam_config"
end
