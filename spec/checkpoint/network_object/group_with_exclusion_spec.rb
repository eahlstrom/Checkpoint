require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::GroupWithExclusion do
  let(:obj_hash) do
    {
      :name=>"group1_but_not_group2", :type=>"group_with_exclusion", :class_name=>"group_with_exception", :comments=>"", 
      :base_name=> {
        :class_name=>"network_object_group", :type=>"group", :comments=>"", :name=>"Group_1", 
        :grp_members=>[{:ipaddr=>"10.1.0.0", :netmask=>"255.255.0.0", :type=>"network", :comments=>"", :name=>"net1", :class_name=>"network"}]
      },
      :exception_name=> {
        :class_name=>"network_object_group", :type=>"group", :comments=>"", :name=>"Group_2", 
        :grp_members=>[{:ipaddr=>"10.1.10.0", :netmask=>"255.255.255.0", :type=>"network", :comments=>"", :name=>"net2", :class_name=>"network"}]
      }
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::GroupWithExclusion.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::GroupWithExclusion.new(obj_hash) }

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:group1_but_not_group2")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_name")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end

    it "match if any member in base group match" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.1.2.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.12.100")
    end

    it "not match if matched by exclusion group" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.1.9.1")
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.1.11.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.1.10.1")
    end
  end
end

