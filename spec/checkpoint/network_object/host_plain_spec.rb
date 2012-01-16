require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Host_plain do
  let(:obj_hash) do
    {
      :class_name=>"host_plain", :type=>"host", :comments=>"", :ipaddr=>"10.10.10.1", :name=>"host_name"
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Host_plain.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::Host_plain.new(obj_hash) }

    it "primary ipaddress" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
    end

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:host_name")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

