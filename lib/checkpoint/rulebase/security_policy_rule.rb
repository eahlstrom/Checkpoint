class Checkpoint::Rulebase::SecurityPolicyRule
  include Checkpoint::Helpers::IP

  attr_reader :name
  attr_reader :comment
  attr_reader :number
  attr_reader :action

  def initialize(rule_hash, network_objects, service_objects_hash)
    unless rule_hash.is_a? Hash
      raise ArgumentError, "(rule_hash) Expected class Hash got #{rule_hash.class}" 
    end
    unless network_objects.is_a? Checkpoint::NetworkObject::Handler
      raise ArgumentError, "(network_objects) Expected Checkpoint::NetworkObject::Handler got #{network_objects.class}" 
    end
    unless service_objects_hash.is_a? Hash
      raise ArgumentError, "(service_objects_hash) Expected class Hash got #{service_objects_hash.class}" 
    end

    needed_keys = ["name", "class_name", "rule_number", "comments", "track", "action", "time", "src", "install_on", "dst", "disabled", "services"]
    needed_keys.each do |key|
      raise ArgumentError, "Miss key: #{key} object" unless rule_hash.has_key?(key)
    end
    unknown_keys = rule_hash.keys - needed_keys
    raise ArgumentError, "Got unknow(n) keys in argument: #{unknown_keys.inspect}" unless unknown_keys.empty?


    allow_class = "security_rule"
    unless rule_hash["class_name"] == allow_class
      raise ArgumentError, %{#{self.class}: rule #{rule_hash["rule_number"]} is not a "#{allow_type}" object}
    end

    @match_info = {}
    @number = rule_hash["rule_number"]
    @action = rule_hash["action"]
    @name = rule_hash["name"]
    @comments = rule_hash["comments"]
    @src_list = rule_hash["src"].map do |src|
      network_objects[src]
    end
    @dst_list = rule_hash["dst"].map do |dst|
      network_objects[dst]
    end
    @services_list = Array.new
    rule_hash["services"].each do |srv|
      if service_objects_hash[srv].nil?
        raise ArgumentError, "service_objects_hash miss service: #{srv}"
      end
      srv = Checkpoint::Service.create(service_objects_hash[srv])
      @services_list << srv if srv 
    end

    @rule_hash = rule_hash
  end

  def disabled?
    if @rule_hash["disabled"] == "true" 
      return true 
    else
      return false
    end
  end

  def match_src(src, opts = {:return_raw_array => false, :debug => false})
    raise ArgumentError, "#{self.class}: src: need a Checkpoint::NetworkObject::Matcher got a #{src.class}" unless src.is_a?(Checkpoint::NetworkObject::Matcher)
    match_info ||= Hash.new
    @src_list.each do |src_obj|
      match_info[src_obj.name] = src_obj.match(src)
    end
    puts "  src_match: #{match_info.inspect}" if opts[:debug]
    if match_info.values.grep(true).empty?
      return [false, match_info]
    end
    return [true, match_info]
  end

  def match_dst(dst, opts = {:return_raw_array => false, :debug => false})
    raise ArgumentError, "#{self.class}: dst: need a Checkpoint::NetworkObject::Matcher got a #{dst.class}" unless dst.is_a?(Checkpoint::NetworkObject::Matcher)
    match_info ||= Hash.new
    @dst_list.each do |dst_obj|
      match_info[dst_obj.name] = dst_obj.match(dst)
    end
    puts "  dst_match: #{match_info.inspect}" if opts[:debug]
    if match_info.values.grep(true).empty?
      return [false, match_info]
    end
    return [true, match_info]
  end

  def match_service(srv, opts = {:return_raw_array => false, :debug => false})
    unless srv.is_a? Checkpoint::Service::Matcher
      raise ArgumentError, "#{self.class}: srv: need a Checkpoint::Service::Matcher got a #{srv.class}" 
    end
    match_info ||= Hash.new
    @services_list.each do |srv_obj|
      begin
        match_info[srv_obj.name] = srv_obj.match(srv)
      rescue => e
        puts "@services_list: #{@services_list.inspect}" 
        puts "srv_obj:        #{srv_obj.inspect}"
        puts "match_srv:      #{srv.inspect}"
        puts "@rule_hash:"
        pp @rule_hash
        puts
        raise e
      end
    end
    puts "  srv_match: #{match_info.inspect}" if opts[:debug]
    if match_info.values.grep(true).empty?
      return [false, match_info]
    end
    return [true, match_info]
  end

  def match(src, dst, srv, opts = {:return_raw_array => false, :debug => false})
    raise ArgumentError, "#{self.class}: src: need a Checkpoint::NetworkObject::Matcher got a #{src.class}" unless src.is_a?(Checkpoint::NetworkObject::Matcher)
    raise ArgumentError, "#{self.class}: dst: need a Checkpoint::NetworkObject::Matcher got a #{dst.class}" unless dst.is_a?(Checkpoint::NetworkObject::Matcher)
    raise ArgumentError, "#{self.class}: srv: need a Checkpoint::Service::Matcher got a #{srv.class}" unless srv.is_a?(Checkpoint::Service::Matcher)
    raise ArgumentError, "#{self.class}: opts: need a Hash got a #{opts.class}" unless opts.is_a?(Hash)

    match_info = { :number => @number, 
                   :name => @name, 
                   :comments => @comments,
                   :action => @action,
                   }

    puts "in rule #{@number}..." if opts[:debug]
    
    # src match
    (result, match_info[:src]) = match_src(src, opts)
    return [false, match_info] unless result

    # dst match
    (result, match_info[:dst]) = match_dst(dst, opts)
    return [false, match_info] unless result

    # service match
    (result, match_info[:service]) = match_service(srv, opts)
    return [false, match_info] unless result

    return [true, match_info]
  end

  def match_rule(rule_match_object)
    unless rule_match_object.is_a? SecurityPolicyRuleMatch
      raise ArgumentError, "Expected SecurityPolicyRuleMatch got #{rule_match_object.class}"
    end
  end
end
