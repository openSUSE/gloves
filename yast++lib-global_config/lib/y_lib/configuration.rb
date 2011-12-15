require "singleton"
require "dbus_clients/dbus_client"

module YLib
  class Configuration
    include Singleton
    attr_accessor :chroot

    def agent_parameters
      ret = {}
      ret["__chroot"] = chroot if chroot
      return ret
    end
  end
end

#reopen config_agents so all ylib implicitelly use agent parameters
module DbusClients
  module DbusClient
    class << self
      alias_method :ylib_conf_extended_call, :call
      def self.call name, id, type, method, options
        options = YLib::Configuration.instance.agent_parameters.merge options
        ylib_conf_extended_call name, id, type, method, options
      end
    end
  end
end
