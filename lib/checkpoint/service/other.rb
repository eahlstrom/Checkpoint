class Checkpoint::Service::Other
  attr_reader :name

  def initialize(object_hash)
    unless object_hash.class == Hash
      raise ArgumentError, "Expected class Hash got #{object_hash.class}"
    end

    needed_keys = [:comments, :type, :protocol, :class_name, :include_in_any, :name, :exp]
    needed_keys.each do |key|
      raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
    end
    unknown_keys = object_hash.keys - needed_keys
    raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


    allow_type = "other"
    unless object_hash[:type] == allow_type
      raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
    end

    @name = object_hash[:name]
    @proto = object_hash[:protocol].to_i
  end

  
  #
  # match against a Checkpoint::Service::Matcher object
  #
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

    return (match_obj.proto == @proto)
  end
end
