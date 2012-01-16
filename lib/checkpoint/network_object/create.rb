module Checkpoint::NetworkObject
  CLASS_FOR_TYPE = {
    "host_plain"            => Host_plain,
    "host_ckp"              => Host_ckp,
    "network_object_group"  => Group,
    "network"               => Network,
    "voip_GK_domain"        => VoipGk,
    "gateway_ckp"           => Gateway_ckp,
    "gateway_plain"         => Gateway_plain,
    "address_range"         => Range,
    "cluster_member"        => ClusterMember,
    "dynamic_object"        => DynamicNetObj,
    "gateway_cluster"       => GatewayCluster,
    "group_with_exception"  => GroupWithExclusion,
    "any_type"              => Checkpoint::SharedObjects::AnyObject,
  } unless defined? CLASS_FOR_TYPE

  #
  # Factory class for creating NetworkObject from a Hash.
  #
  # hsh_obj should be in the same format as 
  # Checkpoint::Parse::NetworkObjectsXml returns
  #
  # *example*
  #
  #   Checkpoint::NetworkObject.create(
  #     :name=>"host1", 
  #     :comments=>"", 
  #     :type=>"host", 
  #     :class_name=>"host_plain", 
  #     :ipaddr=>"10.10.10.10"
  #   ) 
  #   => #<Checkpoint::NetworkObject::Host_plain:0x0000000222c4a8 
  #       @name="host1", @my_ip_obj=#<IPAddr: IPv4:10.10.10.10/255.255.255.255>>
  #
  def create(hsh_obj)
    unless hsh_obj.is_a?(Hash)
      raise ArgumentError, "#{self.inspect}.create: Expected Hash got #{hsh_obj.class}"
    end
    unless hsh_obj.has_key?(:class_name)
      pp hsh_obj
      raise ArgumentError, "#{self.inspect}.create: hsh_obj missing key :type"
    end
    unless CLASS_FOR_TYPE.has_key?(hsh_obj[:class_name])
      pp hsh_obj
      raise ArgumentError, %{#{self.inspect}.create: Dont have an hsh_object def for type "#{hsh_obj[:class_name]}"}
    end
    return CLASS_FOR_TYPE[hsh_obj[:class_name]].new(hsh_obj)
  end
  module_function :create
end
