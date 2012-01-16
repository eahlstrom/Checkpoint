require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Gateway_plain do
  let(:obj_hash) do
    {
      :type=>"gateway", :name=>"other_gw", :enc_domain=>"enc_other_gw", :comments=>"", 
      :ipaddr=>"10.10.10.1", 
      :interfaces=>[
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.10.1", "officialname"=>"eth0"},
        {"netmask"=>"255.255.255.0", "ipaddr"=>"10.10.11.1", "officialname"=>"eth1"},
      ],
      :class_name=>"gateway_plain"
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Gateway_plain.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::Gateway_plain.new(obj_hash) }

    it "primary ipaddress" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
    end

    it "ipaddress defined on its interfaces" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.12.1")
    end

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:other_gw")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

