
class Checkpoint::Service::Matcher
  attr_reader :type
  attr_reader :proto
  attr_reader :port
  attr_reader :end_port
  attr_reader :icmp_code
  attr_reader :icmp_type
  attr_reader :object_name
  #
  # opts =>
  #   {:proto => :tcp | :udp, :port => 22 }
  #   {:proto => :tcp | :udp, :port => 22, :end_port => 25 }
  #   {:proto => :icmp, :code => 8, :type => 3 }
  #
  def initialize(opts)
    @type         = false
    @proto        = false
    @port         = false
    @end_port     = false
    @icmp_code    = false
    @icmp_type    = false
    @object_name  = false
    opts = parse_opts(opts)
  end

  def parse_opts(opts)
    protocols = { :icmp => 1, :tcp => 6, :udp => 17}
    unless opts.is_a? Hash
      raise ArgumentError, "Expected Hash got #{opts.class}"
    end
    if opts.has_key? :object_name
      @type = :object_name
      @object_name = opts[:object_name]
      return
    elsif opts.has_key? :any
      @type = :any 
      return
    end

    raise ArgumentError, "Miss required key :proto" unless opts.has_key? :proto
    @type = :match_by_proto
    if opts[:proto] == :tcp or opts[:proto] == :udp
      @proto = protocols[opts[:proto]]
      raise ArgumentError, "Miss required key :port" unless opts.has_key? :port
      raise ArgumentError, ":port, Expected Integer, got #{opts[:port].class}" unless opts[:port].is_a? Integer
      @port = opts[:port]
      if opts.has_key? :end_port
        raise ArgumentError, ":end_port, Expected Integer, got #{opts[:port].class}" unless opts[:end_port].is_a? Integer
        @end_port = opts[:end_port]
        unless @end_port >= @port
          raise ArgumentError, "end_port cannot be less than port"
        end
      end
    elsif opts[:proto] == :icmp
      @proto = protocols[:icmp]
      @icmp_code = opts[:icmp_code] if opts.has_key?(:icmp_code)
      @icmp_type = opts[:icmp_type] if opts.has_key?(:icmp_type)
    elsif opts[:proto].is_a? Integer
      @proto = opts[:proto]
    else
      raise ArgumentError, "No support for :proto #{opts[:proto]}"
    end
  end

  # "tcp:22"
  # "udp:53-67"
  # "icmp"
  # "icmp:code8"
  # "icmp:code8:type4"
  # "proto:17"
  # "name:object_name"
  # "any"
  #  ==> SrvMatchObject.new object
  def self.new_s(string)
    unless string.is_a? String
      raise ArgumentError, "Expected String got #{string.class}"
    end

    case string
    when /^(tcp|udp):/
      proto = $1
      if string =~ /^(tcp|udp):(\S+)$/
        (port, end_port) = $2.split("-")
        if end_port.nil?
          return self.new(:proto=>proto.to_sym, :port=>port.to_i)
        else
          return self.new(:proto=>proto.to_sym, :port=>port.to_i, :end_port=>end_port.to_i)
        end
      end
    when /^(icmp):(code\d+|type\d+)/
      (code, type) = false
      icmp_code = $1.to_i if string =~ /:code(\d+)/
      icmp_type = $1.to_i if string =~ /:type(\d+)/
      if icmp_code && icmp_type
        return self.new(:proto=>:icmp, :icmp_code => icmp_code, :icmp_type => icmp_type)
      elsif icmp_code
        return self.new(:proto=>:icmp, :icmp_code => icmp_code)
      elsif icmp_type
        return self.new(:proto=>:icmp, :icmp_type => icmp_type)
      end
    when /^(icmp)$/
      return self.new(:proto=>:icmp)
    when /^name:(\S+)$/
      return self.new(:object_name=>$1)
    when /^proto:(\d+)$/
      return self.new(:proto=>$1.to_i)
    when /^any$/
      return self.new(:any => true)
    else
      raise ArgumentError, "service string format error."
    end
  end
end
