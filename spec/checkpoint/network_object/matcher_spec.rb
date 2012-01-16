require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Matcher do
  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Matcher.new({:type=>:ip, :valid_ipv4=>"10.1.1.1"})
    }.should_not raise_error
  end

  describe "Checkpoint::NetworkObject::Matcher.new_s(string)" do
    describe "create object from string" do
      it "ipaddress" do
        o = Checkpoint::NetworkObject::Matcher.new_s('192.168.1.1')
        o.type.should == :ip
        o.ip.should == "192.168.1.1"
        o.end_ip.should be_false
      end

      it "cidr" do
        o = Checkpoint::NetworkObject::Matcher.new_s("192.168.1.0/24")
        o.type.should == :ip
        o.ip.should == IPAddr.new("192.168.1.0/24")
      end

      it "ip/netmask" do
        o = Checkpoint::NetworkObject::Matcher.new_s("192.168.1.1/255.255.255.0")
        o.type.should == :ip
        o.ip.should == IPAddr.new("192.168.1.0/24")
      end

      it "range" do
        o = Checkpoint::NetworkObject::Matcher.new_s("10.1.1.1-10.1.1.2")
        o.type.should == :range
        o.ip.should == IPAddr.new("10.1.1.1")
        o.end_ip.should == IPAddr.new("10.1.1.2")
      end

      it "name" do
        o = Checkpoint::NetworkObject::Matcher.new_s("name:my_name")
        o.type.should == :netobject_name
        o.netobject_name.should == 'my_name'
      end

      it "any" do
        o = Checkpoint::NetworkObject::Matcher.new_s("any")
        o.type.should == :any
      end
    end
  end
end
