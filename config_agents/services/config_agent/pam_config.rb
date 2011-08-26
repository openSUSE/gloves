require 'dbus_services/script_service'

module ConfigAgent
  class PamConfig < DbusServices::ScriptService

    # identification of relevant DBUS service
    agent_id "sbin_pam_config"

    def execute(params)
      exec_params	= params["exec_params"] || ""
      run "/usr/sbin/pam-config #{exec_params}" #FIXME escape parameters
    end
  end
end
