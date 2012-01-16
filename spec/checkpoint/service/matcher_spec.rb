require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service::Matcher do
  describe "Checkpoint::Service::Matcher.new_s(string)" do
    it %{should create matcher for tcp port 22 when "tcp:22"} do
      o = Checkpoint::Service::Matcher.new_s('tcp:22')
      o.proto.should == 6
      o.port.should == 22
    end

    it %{should create matcher for tcp port range 100-200 when "tcp:100-200"} do
      o = Checkpoint::Service::Matcher.new_s('tcp:100-200')
      o.proto.should == 6
      o.port.should == 100
      o.end_port.should == 200
    end

    it %{should create matcher for udp port 161 when "udp:161"} do
      o = Checkpoint::Service::Matcher.new_s('udp:161')
      o.proto.should == 17
      o.port.should == 161
    end

    it %{should create matcher for udp port range 100-200 when "udp:100-200"} do
      o = Checkpoint::Service::Matcher.new_s('udp:100-200')
      o.proto.should == 17
      o.port.should == 100
      o.end_port.should == 200
    end

    it %{should create matcher for icmp when "icmp"} do
      o = Checkpoint::Service::Matcher.new_s('icmp')
      o.proto.should == 1
      o.icmp_code.should be_false
      o.icmp_type.should be_false
    end

    it %{should create matcher for icmp code 8 when "icmp:code8"} do
      o = Checkpoint::Service::Matcher.new_s('icmp:code8')
      o.proto.should == 1
      o.icmp_code.should == 8
      o.icmp_type.should be_false
    end

    it %{should create matcher for icmp code 8 type 4 when "icmp:code8:type4"} do
      o = Checkpoint::Service::Matcher.new_s('icmp:code8:type4')
      o.proto.should == 1
      o.icmp_code.should == 8
      o.icmp_type.should == 4
    end

    it %{should create matcher for ip protocol 51 when "proto:51"} do
      o = Checkpoint::Service::Matcher.new_s('proto:51')
      o.proto.should == 51
    end

    it %{should create matcher for name object_name when "name:object_name"} do
      o = Checkpoint::Service::Matcher.new_s('name:object_name')
      o.object_name.should == "object_name"
    end

    it %{should create matcher for any when "any"} do
      o = Checkpoint::Service::Matcher.new_s('any')
      o.type.should == :any
    end

  end
end
