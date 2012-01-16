module Checkpoint::NetworkObject

  class Range
    include Checkpoint::Helpers::IP
    attr_reader :name
    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:class_name, :ipaddr_first, :type, :ipaddr_last, :comments, :name]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


      allow_type = "address_range"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
      @start_ip = IPAddr.new(object_hash[:ipaddr_first])
      @end_ip = IPAddr.new(object_hash[:ipaddr_last])
      if @start_ip.to_i > @end_ip.to_i
        raise ArgumentError, "#{self.class}: start_ip cannot be larger then end_ip"
      end
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end

      case match_obj.type
      when :ip
        return match_obj.ip.to_i.between?(@start_ip.to_i, @end_ip.to_i)
      when :range
        if match_obj.ip.to_i.between?(@start_ip.to_i, @end_ip.to_i)
          return match_obj.end_ip.to_i.between?(@start_ip.to_i, @end_ip.to_i)
        else
          return false
        end
      when :netobject_name
        return match_obj.netobject_name == @name
      when :any
        return true
      else
        return false
      end
    end

    def to_string
      %{Range: #{@name} (#{@start_ip}-#{@end_ip})}
    end
  end # class

end # module
