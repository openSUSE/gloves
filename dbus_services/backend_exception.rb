module DbusServices
  class BackendException < StandardError
    attr_reader :type

    def initialize(msg,type)
      super(msg)
      @type = type
    end

    def to_hash
      return { 
        "error" => message,
        "backtrace" => backtrace,
        "error_type" => type
      }
    end
  end
end
