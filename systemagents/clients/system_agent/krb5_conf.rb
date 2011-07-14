require 'dbus_clients/file_client'

module SystemAgent
  class Krb5Conf < DbusClients::FileClient

    # identification of relevant DBUS service
    filename "etc_krb5_conf"
  end
end
