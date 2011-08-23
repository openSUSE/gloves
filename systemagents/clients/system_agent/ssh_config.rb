require 'dbus_clients/file_client'

module SystemAgent
  class SshConfig < DbusClients::FileClient

    # identification of relevant DBUS service
    filename "etc_ssh_ssh_config"
  end
end
