require 'dbus_services/script_service'

module SystemAgents
  class PamConfig < DbusServices::ScriptService

    # identification of relevant DBUS service
    filename "pam_config"

    def execute(params)

      exec_params	= params["exec_params"] || ""

      pam_krb5    = `pam-config #{exec_params}`

      ret	= {
        "stdout"	=> pam_krb5
      }
      return ret
    end

  end
end
