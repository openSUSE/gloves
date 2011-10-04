require "augeas"

module DbusServices
  module AugeasSerializer

    def augeas_load (path,lense,options={})
      aug = Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => lense, :incl => path)
      aug.load
      augeas_to_hash(aug,"/files#{path}")
    end

    private
      def augeas_to_hash ( aug,path )
        reduction_func = Proc.new do |res,path|
          item = path.split("/").last
          if match = /^(.+)\[(\d+)\]$/.match(item)
            res[match[1]] ||= []
            res[match[1]][match[2].to_i] = augeas_to_hash(aug,path)
          else
            res[item] = augeas_to_hash(aug,path)
          end
          res
        end
        res = aug.match(path+"/*").reduce({},&reduction_func)
        res = aug.get(path) if res.empty?
        return res
      end

  end
end
