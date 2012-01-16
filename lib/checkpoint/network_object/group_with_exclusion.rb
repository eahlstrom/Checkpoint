module Checkpoint::NetworkObject

  class GroupWithExclusion
    attr_reader :name

    include Checkpoint::Helpers::IP
    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:type, :comments, :exception_name, :class_name, :name, :base_name]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?

      allow_type = "group_with_exception"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
      @base_group = Checkpoint::NetworkObject.create(object_hash[:base_name])
      @exeption_group = Checkpoint::NetworkObject.create(object_hash[:exception_name])
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end

      case match_obj.type
      when :any
        return true
      when :ip
        return @base_group.match(match_obj) && !@exeption_group.match(match_obj)
      when :netobject_name
        return match_obj.netobject_name == name
      else
        return false
      end
    end

    def to_string
      "GroupWithExclusion \"#{name}\":\n" +
        " obj in: #{@base_group.to_string}\n" +
        " except: #{@exeption_group.to_string}"
    end
  end # class

end # module
