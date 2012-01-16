require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::DynamicNetObj do
  let(:obj_hash) do
    {
      :class_name => "dynamic_object", 
      :type => "dynamic_net_obj", 
      :comments => "dyn object",
      :bogus_ip => "0.0.0.1",
      :name => "dyn_obj"
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::DynamicNetObj.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::DynamicNetObj.new(obj_hash) }

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:dyn_obj")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:other_dyn_obj")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end
