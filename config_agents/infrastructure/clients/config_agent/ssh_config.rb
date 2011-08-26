require 'dbus_clients/file_client'

module ConfigAgent
  class SshConfig < DbusClients::FileClient

    # identification of relevant DBUS service
    agent_id "etc_ssh_ssh_config"
  end
end
