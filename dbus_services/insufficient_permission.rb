require "dbus_services/backend_exception"

module DbusServices
  class InsufficientPermission < BackendException
    attr_reader :permission
    def initialize(permission)
      super("Permission(#{permission} not granted.","ERR_PERMISSION")
      @permission = permission
    end

    def to_hash
      ret = super
      ret["permission"] = permission
      return ret
    end
  end
end
