require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Network do
  let(:obj_hash) do
    {
      :ipaddr=>"10.10.10.0", :netmask=>"255.255.255.0", :type=>"network",
      :name=>"net_ett", :class_name=>"network", :comments=>""
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Network.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::Network.new(obj_hash) }

    it "ipaddress within its network" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.255")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.1")
    end

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:net_ett")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

