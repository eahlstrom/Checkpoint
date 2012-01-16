module Checkpoint::NetworkObject

  class ClusterMember
    include Checkpoint::Helpers::IP
    attr_reader :name

    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:class_name, :type, :interfaces, :comments, :ipaddr, :name, :machine_weight]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?

      allow_type = "cluster_member"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @firewall_installed = true
      unless object_hash[:firewall] == "installed"
        @firewall_installed = false
      end

      @name = object_hash[:name]
      @my_ip_obj = IPAddr.new(object_hash[:ipaddr])
      @interfaces = object_hash[:interfaces].map do |interface|
        Checkpoint::NetworkObject::NetworkInterface.new(interface)
      end
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end
      if match_obj.type == :ip
        return true if @my_ip_obj.include?(match_obj.ip)
        @interfaces.each do |interface|
          return true if interface.include?(match_obj.ip)
        end
      elsif match_obj.type == :netobject_name
        return true if match_obj.netobject_name == @name
      elsif match_obj.type == :any
        return true
      end
      return false
    end

    def to_string
      str = "ClusterMember: #{@name} (#{@my_ip_obj.to_s}) "
      str += " Interfaces: "
      str += (@interfaces.collect {|i| i.to_s}).join(",")
    end
  end # class

end # module
