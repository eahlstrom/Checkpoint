require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::VoipGk do
  let(:obj_hash) do
    {
      :zone_range_name=> {
        :type=>"group", :comments=>"", 
        :grp_members=> [
          {:ipaddr=>"10.10.10.0", :type=>"network", :netmask=>"255.255.255.0", :comments=>"", :class_name=>"network", :name=>"net_ett"}
        ],
        :class_name=>"network_object_group",
        :name=>"H323_voip_domain"
      },
      :type=>"voip_gk",
      :h323_gatekeeper_protocols_h323_gatekeeper_protocols=>"RTP/RTCP",
      :comments=>"",
      :class_name=>"voip_GK_domain",
      :name=>"H323_gk",
      :server_name=> {
        :ipaddr=>"10.10.10.1",
        :type=>"host",
        :comments=>"",
        :class_name=>"host_plain",
        :name=>"server"
      }
    }
  end

  it "should create an instance" do
    lambda {
      Checkpoint::NetworkObject::VoipGk.new(obj_hash)
    }.should_not raise_error
  end

  describe "matches on" do
    let(:o) { Checkpoint::NetworkObject::VoipGk.new(obj_hash) }

    it "ipaddress on server" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.1")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("10.10.10.2")
    end

    it "object name" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("name:H323_gk")
      o.should_not match Checkpoint::NetworkObject::Matcher.new_s("name:server")
    end

    it ":any object" do
      o.should match Checkpoint::NetworkObject::Matcher.new_s("any")
    end
  end
end

