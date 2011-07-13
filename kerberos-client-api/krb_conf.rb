require "dbus_clients/file_client"

class KrbConf < DbusClients::FileClient
  filename "_etc_krb5_conf"
end
