require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Range do
  let(:obj_hash) do
    {
      :class_name=>"address_range", :type=>"machines_range", 
      :comments=>"", :name=>"range_name",
      :ipaddr_first=>"10.10.10.10", :ipaddr_last=>"10.10.10.20", 
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Range.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::Range.new(obj_hash) }

    it "ipaddress within range" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.10")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.20")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.9")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.21")
    end

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:range_name")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

