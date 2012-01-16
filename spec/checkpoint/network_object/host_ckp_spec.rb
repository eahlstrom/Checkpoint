require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Host_ckp do
  let(:obj_hash) do
    {
      :type=>"host", :management=>"true", :primary_management=>"true", :name=>"management",
      :log_server=>"true", :comments=>"", :firewall=>"not-installed", :ipaddr=>"10.10.10.1",
      :interfaces=> [
        {"netmask"=>"255.255.255.0", "officialname"=>"eth0", "ipaddr"=>"10.10.10.1"},
        {"netmask"=>"255.255.255.0", "officialname"=>"eth1", "ipaddr"=>"10.10.10.2"}
      ],
      :class_name=>"host_ckp"
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Host_ckp.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::Host_ckp.new(obj_hash) }

    it "primary ipaddress" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.3")
    end

    it "ipaddress defined on its interfaces" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.4")
    end

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:management")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

