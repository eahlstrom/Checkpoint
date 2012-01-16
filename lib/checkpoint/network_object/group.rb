module Checkpoint::NetworkObject
  class Group
    attr_reader :name
    attr_reader :last_matching_member
    include Checkpoint::Helpers::IP

    def initialize(object_hash)
      unless object_hash.class == Hash
        raise ArgumentError, "Expected class Hash got #{object_hash.class}"
      end

      needed_keys = [:class_name, :type, :comments, :name, :grp_members]
      needed_keys.each do |key|
        raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
      end
      unknown_keys = object_hash.keys - needed_keys
      raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


      allow_type = "network_object_group"
      unless object_hash[:class_name] == allow_type
        raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
      end

      @name = object_hash[:name]
      @last_matching_member = nil
      @members = Array.new 
      object_hash[:grp_members].each do |member|
        @members << Checkpoint::NetworkObject.create(member)
      end
    end

    def match(match_obj)
      unless match_obj.is_a?(Checkpoint::NetworkObject::Matcher)
        raise ArgumentError, "Expected: Checkpoint::NetworkObject::Matcher got #{match_obj.class}"
      end
      @last_matching_member = nil

      if match_obj.type == :netobject_name
        return true if match_obj.netobject_name == @name
      elsif match_obj.type == :any
        return true
      end

      @members.each do |member_object|
        if member_object.match(match_obj)
          @last_matching_member = member_object.name
          return true 
        end
      end
      return false
    end

    def members
      return @members.map do |member_object|
        member_object.name
      end
    end

    def to_string
      string = %{Group "#{@name}":\n}
      @members.each do |member|
        member.to_string.each_line do |line|
          line.chomp!
          string += "  #{line}\n"
        end
      end
      return string
    end
  end

end # module GroupObject
