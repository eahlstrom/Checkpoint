module Checkpoint::Service

  CLASS_FOR_TYPE = {
    "tcp"                => TCPport,
    "udp"                => UDPport,
    "icmp"               => ICMP,
    "other"              => Other,
    "any_type"           => Checkpoint::SharedObjects::AnyObject,
    "group"              => Group,
    "gtp_v1"             => :skip,
    "gtp"                => :skip,
    "dcerpc"             => :skip,
    "rpc"                => :skip,
    "tcp_citrix"         => :skip,
    "tcp_subservice"     => :skip,
    "gtp_mm_v0"          => :skip,
    "gtp_mm_v1"          => :skip,
    "icmpv6"             => :skip,
  }


  def create(obj)
    unless obj.is_a?(Hash)
      raise ArgumentError, "#{self.inspect}.create: Expected Hash got #{obj.class}"
    end
    unless obj.has_key?(:type)
      raise ArgumentError, "#{self.inspect}.create: obj missing key :type"
    end
    unless CLASS_FOR_TYPE.has_key?(obj[:type])
      raise ArgumentError, %{#{self.inspect}.create: Dont have an object def for type "#{obj[:type]}"}
    end

    return false if CLASS_FOR_TYPE[obj[:type]] == :skip
    return CLASS_FOR_TYPE[obj[:type]].new(obj)
  end
  module_function :create

end
