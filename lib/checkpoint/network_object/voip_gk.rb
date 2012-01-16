module Checkpoint::NetworkObject
  class VoipGk
    include Checkpoint::Helpers::IP
    attr_reader :name

    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:zone_range_name, :type, :h323_gatekeeper_protocols_h323_gatekeeper_protocols, :comments, :class_name, :name, :server_name]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


      allow_type = "voip_GK_domain"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
      @server_name = Checkpoint::NetworkObject.create(object_hash[:server_name])
      @zone_range  = Checkpoint::NetworkObject.create(object_hash[:zone_range_name])
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end

      case match_obj.type
      when :ip
        return true if @server_name.match(match_obj)
      when :netobject_name
        return true if match_obj.netobject_name == @name
      when :any
        return true
      else
        return false
      end
    end
  end
end
