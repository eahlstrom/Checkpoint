module Checkpoint::NetworkObject

  class NetworkInterface
    include Checkpoint::Helpers::IP
    attr_reader :name
    attr_reader :my_ipaddress
    attr_reader :my_network_object

    def initialize(object_hash)
      @verbose_errors = false
      require 'pp' if @verbose_errors
      unless object_hash.class == Hash
        pp object_hash if @verbose_errors
        raise ArgumentError, "#{self.class}: Expected class Hash got #{object_hash.class}"
      end

      needed_keys = %w{ipaddr netmask officialname}
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?

      @name = object_hash["officialname"]
      @my_ipaddress = IPAddr.new(object_hash["ipaddr"])
      @my_network_object = IPAddr.new(object_hash["ipaddr"] + "/" + object_hash["netmask"])
    end

    # match with Checkpoint::NetworkObject::Matcher
    #
    # => true/false
    #
    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end
      case match_obj.type
      when :any
        return true
      when :ip
        return @my_ipaddress.include?(match_obj.ip)
      else
        return false
      end
    end

    def include?(ipaddr_object)
      return @my_ipaddress.include?(ipaddr_object)
    end
    
    #
    # Check if this inbound ipaddress is valid to come via this interface.
    #
    def this_net_spoof_match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end
      case match_obj.type
      when :ip
        return @my_network_object.include?(match_obj.ip)
      when :range
        if @my_network_object.include?(match_obj.ip)
          return true if @my_network_object.include?(match_obj.end_ip)
        else
          return false
        end
      else
        pp match_obj if @verbose_errors
        raise ArgumentError, %{#{self.class}: invalid ip/range}
      end
      return false 
    end

    def to_string
      %{#{@name}(#{@my_ipaddress.to_s})}
    end

  end # class
end # module
