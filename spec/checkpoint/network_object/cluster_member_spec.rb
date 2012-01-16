require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::ClusterMember do
  let(:cluster_member_hash) do
    { 
      :class_name=>"cluster_member", :type=>"cluster_member", :comments=>"", :ipaddr=>"10.10.10.1", :name=>"clust-member", :machine_weight=>"1",
      :interfaces=>[
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.10.1", "officialname"=>"eth0"},
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.11.1", "officialname"=>"eth1"},
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.12.1", "officialname"=>"eth2"}
      ]
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::ClusterMember.new(cluster_member_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::ClusterMember.new(cluster_member_hash) }
 
    it "ipaddress" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
    end

    it "ipaddress on a defined interface" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
    end

    it "its name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:clust-member")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other-clust-member")
    end
  
    it "should always match :any" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

