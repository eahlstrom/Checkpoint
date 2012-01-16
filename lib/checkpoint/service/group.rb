class Checkpoint::Service::Group
  attr_reader :name
  attr_reader :last_matching_member

  def initialize(object_hash)
    unless object_hash.class == Hash
      raise ArgumentError, "Expected class Hash got #{object_hash.class}"
    end

    needed_keys = [:type, :include_in_any, :name, :grp_members, :comments, :class_name]
    needed_keys.each do |key|
      raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
    end
    unknown_keys = object_hash.keys - needed_keys
    raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


    allow_type = "group"
    unless object_hash[:type] == allow_type
      raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
    end

    @name = object_hash[:name]
    @last_matching_member = nil
    @members = Array.new 
    object_hash[:grp_members].each do |member|
      @members << Checkpoint::Service.create(member)
    end
  end

  def match(match_obj)
    unless match_obj.is_a? Checkpoint::Service::Matcher
      raise ArgumentError, "#{self.class}: need a Checkpoint::Service::Matcher got a #{match_obj.class}" 
    end

    if match_obj.object_name
      return match_obj.object_name == @name
    end

    if match_obj.type == :any
      return true
    end

    @last_matching_member = nil
    @members.each do |member_object|
      # skip match of object if it's a unhandled Class (:skip -> FalseClass).
      next unless member_object 

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
end
