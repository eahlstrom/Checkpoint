module Checkpoint::NetworkObject
  class DynamicNetObj
    include Checkpoint::Helpers::IP
    attr_reader :name

    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:class_name, :type, :comments, :bogus_ip, :name]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?

      allow_type = "dynamic_object"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
    end

    #
    # match against a Checkpoint::NetworkObject::Matcher
    #
    # it will only match on :netobject_name
    # and object type :any 
    #
    def match(match_obj)
      if match_obj.type == :netobject_name
        return true if match_obj.netobject_name == @name
      elsif match_obj.type == :any
        return true
      end
      return false
    end

    def to_string
      "DynObj: #{name}"
    end
  end # class

end # module
