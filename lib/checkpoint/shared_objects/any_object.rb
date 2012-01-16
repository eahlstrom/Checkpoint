
module Checkpoint::SharedObjects

  class AnyObject
    attr_reader :name

    def initialize(obj)
      unless obj.is_a?(Hash)
        raise ArgumentError, "Need a Hash got a #{obj.class}" 
      end
      unless obj[:type] == "any_type"
        raise ArgumentError, "I'm only a any_type, not a -> #{obj[:type]} type"
      end
      @name = "Any"
    end

    def match(*args)
      return true
    end

    def to_string
      "Any"
    end
  end

end
