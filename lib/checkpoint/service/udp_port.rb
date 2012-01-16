class Checkpoint::Service::UDPport
  attr_reader :name

  def initialize(object_hash)
    unless object_hash.class == Hash
      raise ArgumentError, "Expected class Hash got #{object_hash.class}"
    end


    needed_keys = [:comments, :type, :class_name, :include_in_any, :name, :proto_type_name, :port]
    needed_keys.each do |key|
      raise ArgumentError, "Miss key: #{key} object" unless object_hash.has_key?(key)
    end
    unknown_keys = object_hash.keys - needed_keys
    raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


    allow_type = "udp"
    unless object_hash[:type] == allow_type
      raise ArgumentError, %{#{self.class}: #{object_hash[:name]} is not a "#{allow_type}" object}
    end

    @name = object_hash[:name]
    if object_hash[:port] =~ /^>(\d+)/
      @min = $1.to_i
      @max = 65535
    elsif object_hash[:port] =~ /^<(\d+)/
      @min = 1
      @max = $1.to_i
    else
      (@min,@max) = object_hash[:port].split("-")
      @min = @min.to_i
      if @max.nil?
        @max = @min
      else
        @max = @max.to_i
      end
      if @min > @max
        raise ArgumentError, "min(#{@min}) cannot be greater than max(#{@max})"
      end
    end
  end
  
  # Check if this service match match_obj (Checkpoint::Service::Matcher)
  #
  #   domain.match Checkpoint::Service::Matcher.new_s('udp:53') => true
  #
  def match(match_obj)
    unless match_obj.is_a? Checkpoint::Service::Matcher
      raise ArgumentError, "#{self.class}: need a Checkpoint::Service::Matcher got a #{match_obj.class}" 
    end

    if match_obj.object_name
      return match_obj.object_name == @name
    end

    return true if match_obj.type == :any
    return false if match_obj.proto != 17

    if match_obj.end_port
      return @min.between?(match_obj.port, match_obj.end_port) &&
        @max.between?(match_obj.port, match_obj.end_port)
    else
      return match_obj.port.between?(@min, @max)
    end
  end
end

