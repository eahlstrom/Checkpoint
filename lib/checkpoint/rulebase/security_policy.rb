class Checkpoint::Rulebase::SecurityPolicy
  attr_reader :match_info
  attr_reader :name

  def initialize(rulebase_hash, network_objects, services_objects_hash, connect_to_fw=false)
    unless rulebase_hash.class == Hash
      raise ArgumentError, "rulebase_hash: Expected class Hash got #{rulebase_hash.class}"
    end
    unless network_objects.is_a? Checkpoint::NetworkObject::Handler
      raise ArgumentError, "network_objects: Expected class Checkpoint::NetworkObject::Handler got #{network_objects.class}"
    end
    unless services_objects_hash.class == Hash
      raise ArgumentError, "services_objects_hash: Expected class Hash got #{services_objects_hash.class}"
    end

    unless connect_to_fw
      install_on = Hash.new
      rulebase_hash[:rules].each do |rule|
        next if rule.has_key?("header_text")
        install_on[rule["install_on"]] ||= 0
        install_on[rule["install_on"]] += 1
      end
      connect_to_fw = install_on.sort { |x,y| x[1] <=>y[1] }.last[0]
    end
    unless network_objects[connect_to_fw]
      raise "Cannot connect this policy to a fw-module"
    end

    @name = rulebase_hash[:name]
    @fw_module = network_objects[connect_to_fw]
    @rulebase_hash = rulebase_hash
    @network_objects = network_objects
    @services_objects_hash = services_objects_hash
    @network_objects_used = Hash.new

    @rules = Array.new
    @rulebase_hash[:rules].each do |rule|
      next if rule.has_key?("header_text")
      @rules << Checkpoint::Rulebase::SecurityPolicyRule.new(rule, @network_objects, @services_objects_hash)
    end
  end

  def simulate_packet(src, dst, srv, opts={})
    default_opts = {  :debug => false,
                      :return_at_first_match => true, 
                    }
    opts = merge_options(opts, default_opts)

    [src, dst].each do |key|
      raise ArgumentError, "#{self.class}: need a Checkpoint::NetworkObject::Matcher got a #{key.class}" unless key.is_a?(Checkpoint::NetworkObject::Matcher)
    end
    raise ArgumentError, "srv: need a Checkpoint::Service::Matcher got a #{srv.class}" unless srv.is_a?(Checkpoint::Service::Matcher)
    raise ArgumentError, "opts: need a Hash got a #{opts.class}" unless opts.is_a?(Hash)
    match_info = Hash.new
    @rules.each do |rule|
      next if rule.disabled?

      src_dst_port = "#{src.ip} -> #{dst.ip} port #{srv.proto}:#{srv.port}"
      puts "Test rule... #{rule.number} (#{src_dst_port})" if opts[:debug]
      (matched, rule_match_info) = rule.match(src, dst, srv)
      if matched
        puts "== Match rule number: #{rule.number} action -> #{rule.action} ==" if opts[:debug]
        match_info[rule.number.to_i] = rule_match_info
        return match_info if opts[:return_at_first_match]
      end
      puts if opts[:debug]
    end 
    return match_info
  end

  private
  def merge_options(opts, default_opts)
    unless opts.is_a?(Hash)
      return default_opts
    end
    default_opts.each_pair do |key, value|
      opts[key] = value unless opts.has_key?(key)
    end
    return opts
  end
end
