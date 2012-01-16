module Checkpoint::NetworkObject
  class Host_plain
    attr_reader :name

    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:class_name, :type, :comments, :ipaddr, :name]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end

      allow_type = "host_plain"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
      @my_ip_obj = IPAddr.new(object_hash[:ipaddr])
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end
      if match_obj.type == :ip
        return @my_ip_obj.include?(match_obj.ip)
      elsif match_obj.type == :netobject_name
        return true if match_obj.netobject_name == @name
      elsif match_obj.type == :any
        return true
      else
        return false
      end
    end

    def to_string
      %{Host: #{@name} (#{@my_ip_obj.to_s})}
    end

  end # class
end # module HostObject
