class Checkpoint::Service::ICMP
  attr_reader :name

  def initialize(object_hash)
    unless object_hash.class == Hash
      raise ArgumentError, "Expected class Hash got #{object_hash.class}"
    end


    needed_keys = [:comments, :type, :class_name, :icmp_type, :include_in_any, :icmp_code, :name]
    needed_keys.each do |key|
      raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
    end
    unknown_keys = object_hash.keys - needed_keys
    raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


    allow_type = "icmp"
    unless object_hash[:type] == allow_type
      raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
    end

    @name = object_hash[:name]
    @icmp_type = object_hash[:icmp_type]
    if @icmp_type =~ /^(\d+)$/
      @icmp_type = @icmp_type.to_i
    else
      raise ArgumentError, %{Invalid icmp_type: #{object_hash[:icmp_type]}}
    end
    @icmp_code = object_hash[:icmp_code]
    if @icmp_code.nil?
      @icmp_code = :all
    elsif @icmp_code =~ /^\s*$/
      @icmp_code = :all
    else
      @icmp_code = @icmp_code.to_i
    end
  end

  
  #
  # matches a Checkpoint::Service::Matcher object
  #
  def match?(match_obj)
    unless match_obj.is_a? Checkpoint::Service::Matcher
      raise ArgumentError, "#{self.class}: need a Checkpoint::Service::Matcher got a #{match_obj.class}" 
    end

    if match_obj.object_name
      return match_obj.object_name == @name
    end

    if match_obj.type == :any
      return true
    end

    return false unless match_obj.proto == 1

    if match_obj.icmp_type
      return false unless match_obj.icmp_type == @icmp_type
    end
     
    if match_obj.icmp_code
      return false unless match_obj.icmp_code == @icmp_code
    end

    return true
  end
  alias :match :match?
end
