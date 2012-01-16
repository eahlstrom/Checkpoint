module Checkpoint::NetworkObject

  class Network
    include Checkpoint::Helpers::IP
    attr_reader :name

    def initialize(object_hash)
      @verbose_errors = false
      require 'pp' if @verbose_errors
      unless object_hash.class == Hash
        pp object_hash if @verbose_errors
        raise ArgumentError, "#{self.class}: Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:type, :class_name, :netmask, :comments, :name, :ipaddr]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?

      allow_type = "network"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
      @my_ip_obj = IPAddr.new(object_hash[:ipaddr] + "/" + object_hash[:netmask])
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end
      if match_obj.type == :ip
        match = @my_ip_obj.include?(match_obj.ip)
        return match
      elsif match_obj.type == :range
        if @my_ip_obj.include?(match_obj.ip)
          return true if @my_ip_obj.include?(match_obj.end_ip)
        else
          return false
        end
      elsif match_obj.type == :netobject_name
        return true if match_obj.netobject_name == @name
      elsif match_obj.type == :any
        return true
      else
        pp match_obj if @verbose_errors
        raise ArgumentError, %{#{self.class}: invalid ip/range (#{match_obj.inspect})}
      end
      return false 
    end

    def to_string
      %{Network: #{@name} (#{@my_ip_obj.inspect.split(":")[2].gsub(/>$/, "")})}
    end

  end # class Network
end # module 
