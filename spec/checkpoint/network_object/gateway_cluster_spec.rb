require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::GatewayCluster do
  let(:object_hash) do
    member1 = { 
      :class_name=>"cluster_member", :type=>"cluster_member", :comments=>"", :ipaddr=>"10.10.10.2", :name=>"member-1", :machine_weight=>"1",
      :interfaces=> [
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.10.2", "officialname"=>"eth0"},
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.11.2", "officialname"=>"eth1"},
      ]
    }
    member2 = {
      :class_name=>"cluster_member", :type=>"cluster_member", :comments=>"", :ipaddr=>"10.10.10.2", :name=>"member-2", :machine_weight=>"1",
      :interfaces=> [
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.10.3", "officialname"=>"eth0"},
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.11.3", "officialname"=>"eth1"},
      ]
    }

    cluster = {
      :comments=>"my cluster", :type=>"gateway_cluster", :ipaddr=>"10.10.10.1", 
      :cluster_members=>[ member1, member2 ],
      :class_name=>"gateway_cluster", :name=>"gw-cluster", :firewall=>"installed",
      :interfaces=> [
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.10.1", "officialname"=>"eth0"},
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.11.1", "officialname"=>"eth1"},
      ]
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::GatewayCluster.new(object_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::GatewayCluster.new(object_hash) }
 
    it "ipaddress" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.4")
    end

    it "ipaddress on a defined interface of self and members" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.3")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.1")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.2")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.3")
    end

    it "its name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:gw-cluster")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other-clust-member")
    end
  
    it "should always match :any" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

