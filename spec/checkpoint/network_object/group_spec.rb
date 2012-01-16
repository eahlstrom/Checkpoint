require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Group do
  let(:obj_hash) do
    {
      :class_name=>"network_object_group", :type=>"group", :comments=>"", :name=>"grp_name",
      :grp_members=> [
        {:class_name=>"host_plain", :type=>"host", :comments=>"", :ipaddr=>"10.10.10.1", :name=>"host_1"},
        {:netmask=>"255.255.255.0", :type=>"network", :comments=>"Comments", :ipaddr=>"10.10.11.0", :name=>"net", :class_name=>"network"}
      ]
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::Group.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::Group.new(obj_hash) }

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:grp_name")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end

    it "match if any member match" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.11.100")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.12.100")
    end
  end
end

