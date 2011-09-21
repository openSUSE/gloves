module DbusClients
  module Utils
    #taken from active support for automagic
    def self.underscore input
      input.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    BACKEND_LOCATION = "/usr/share/config_agents/services"
    def self.direct_call class_name, method, params
      $LOAD_PATH << BACKEND_LOCATION
      base_name = class_name.split('::').last
      module_path = underscore base_name
      begin
        require "config_agent_service/#{module_path}"
        require "dbus_services/backend_exception"
        begin
          ret = ConfigAgentService.const_get(base_name).send(:new,nil).send(method,params) #name is same
        rescue DbusServices::BackendException => e
          ret = e.to_hash
        end
      ensure
        $LOAD_PATH.pop
      end
      return ret
    end
  end
end
