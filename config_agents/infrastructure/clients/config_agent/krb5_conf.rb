require 'dbus_clients/file_client'

module ConfigAgent
  class Krb5Conf < DbusClients::FileClient

    # identification of relevant DBUS service
    agent_id "etc_krb5_conf"
  end
end
