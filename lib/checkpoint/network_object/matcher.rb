class Checkpoint::NetworkObject::Matcher
  extend Checkpoint::Helpers::IP

  attr_reader :type
  attr_reader :ip
  attr_reader :start_ip
  attr_reader :end_ip
  attr_reader :netobject_name

  #
  # creates a new Matcher.
  #
  # *examples*
  #
  #   Checkpoint::NetworkObject::Matcher.new({:type=>:range, :start_ip=>"10.1.1.1", :end_ip=>"10.1.1.20"}))
  #   Checkpoint::NetworkObject::Matcher.new({:type=>:ip, :valid_ipv4 => "10.1.1.1"})
  #   Checkpoint::NetworkObject::Matcher.new({:type=>:ip, :valid_ipv4 => "10.1.1.0/24"})
  #   Checkpoint::NetworkObject::Matcher.new({:type=>:ip, :valid_ipv4 => "10.1.1.0/255.255.255.0"})
  #   Checkpoint::NetworkObject::Matcher.new({:type=>:any })
  #   Checkpoint::NetworkObject::Matcher.new({:type=>:netobject_name, :netobject_name => "Any|Host10|..." })
  #
  def initialize(opts)
    check_init_arguments(opts)
    
    # Default values
    @type         = opts[:type]
    @ip           = false
    @end_ip       = false
    @netobject_name  = ""

    # Creating IPAddr objects
    if @type == :ip
      @ip = IPAddr.new(opts[:valid_ipv4])
    elsif @type == :range
      @ip = IPAddr.new(opts[:start_ip])
      @end_ip = IPAddr.new(opts[:end_ip])
      if @ip.to_i > @end_ip.to_i
        raise "start_ip cannot be lower than end_ip"
      end
    elsif @type == :netobject_name
      @netobject_name = opts[:netobject_name]
    elsif @type == :any
    else
      raise "Whooops! someone is going wild here!"
    end
  end

  def check_init_arguments(opts)
    unless opts.is_a?(Hash)
      raise ArgumentError, "Expected Hash got #{opts.class}"
    end
    if opts.has_key?(:type)
      case opts[:type]
      when :ip
        unless opts.has_key?(:valid_ipv4)
          raise "type: :ip -> Miss required key \":valid_ipv4\""
        end
      when :range
        unless opts.has_key?(:start_ip)
          raise "type: :range -> Miss required key \":start_ip\""
        end
        unless opts.has_key?(:end_ip)
          raise "type: :range -> Miss required key \":end_ip\""
        end
      when :netobject
        unless opts.has_key?(:netobject)
          raise "type: :netobject -> Miss required key \":netobject\""
        end
      when :netobject_name
        unless opts.has_key?(:netobject_name)
          raise "type: :netobject_name -> Miss required key \":netobject_name\""
        end
      when :any
      else
        raise ArgumentError, "Expected :type -> (:ip|:range|:netobject_name), got \"#{opts[:type]}\""
      end
    else
      raise "Miss required key \":type\""
    end
  end
  private :check_init_arguments

  # Resolves a String, and creates a new object.
  # 
  # *examples*
  #   Matcher.new_s("10.1.1.1")
  #   Matcher.new_s("10.1.1.0/24")
  #   Matcher.new_s("10.1.1.0/255.255.255.0")
  #   Matcher.new_s("10.1.1.1-10.1.1.10")
  #   Matcher.new_s("name:old_tom_morris")
  #   Matcher.new_s("any")
  #
  def self.new_s(str)
    unless str.is_a?(String)
      raise ArgumentError, "Expected String got #{str.class}"
    end

    if valid_ipv4?(str)
      return self.new({:type=>:ip, :valid_ipv4 => str})
    elsif valid_ipv4_cidr?(str)
      return self.new({:type=>:ip, :valid_ipv4 => str})
    elsif valid_ipv4_ipnetmask?(str)
      return self.new({:type=>:ip, :valid_ipv4 => str})
    elsif str =~ /name:(\S+)/
      return self.new(:type=>:netobject_name, :netobject_name=>$1)
    elsif str =~ /^any$/i
      return self.new(:type=>:any)
    else
      (start_ip, end_ip) = str.split("-")
      if valid_ipv4?(start_ip) and valid_ipv4?(end_ip)
        return self.new({:type=>:range, :start_ip => start_ip, :end_ip => end_ip})
      else
        raise ArgumentError, "Unresolvable string. (#{str})"
      end
    end
  end
end
