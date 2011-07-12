$:.unshift(File::join("..", "dbus-infrastructure"))

require 'script_service.rb'

class PamConfig < ScriptService

  # identification of relevant DBUS service
  filename = "pam-config"

  def self.execute(params)

    exec_params	= params["exec_params"] || ""

    pam_krb5    = `pam-config #{exec_params}`

    ret	= {
	"stdout"	=> pam_krb5
    }
    return ret
  end

end
