require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::NetworkInterface do
  let(:obj_hash) do
    {
      "ipaddr" => "10.10.10.1", "netmask" => "255.255.255.0", "officialname" => "eth0"
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::NetworkInterface.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::NetworkInterface.new(obj_hash) }

    it "ipaddress" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end

  describe "this_net_spoof_match(match_obj)" do
    let(:o) { Checkpoint::NetworkObject::NetworkInterface.new(obj_hash) }

    it "should match if matcher is included in network" do
      o.this_net_spoof_match(Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")).should be_true
      o.this_net_spoof_match(Checkpoint::NetworkObject::Matcher.new_s("10.10.10.255")).should be_true
      o.this_net_spoof_match(Checkpoint::NetworkObject::Matcher.new_s("10.10.11.1")).should be_false
    end
  end
end

