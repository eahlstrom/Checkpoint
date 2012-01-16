require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service::ICMP do
  let(:hsh) do
    {
      :comments=>"", :type=>"icmp", :class_name=>"icmp_service", :icmp_type=>"8", :include_in_any=>"", :icmp_code=>"4", :name=>"echo-request"
    }
  end 

  it "should be possible to create instance" do
    lambda {
      udp_obj = Checkpoint::Service::ICMP.new(hsh)
    }.should_not raise_error
  end

  describe "instance" do
    let(:o) {Checkpoint::Service::ICMP.new(hsh)}

    it "should have accessor for name" do
      o.name.should == 'echo-request'
    end

    describe "matching" do
      it "should match object name" do
        o.should match Checkpoint::Service::Matcher.new_s('name:echo-request')
        o.should_not match Checkpoint::Service::Matcher.new_s('name:other')
      end

      it "should match on icmp" do
        o.should match Checkpoint::Service::Matcher.new_s('icmp')
        o.should_not match Checkpoint::Service::Matcher.new_s('tcp:23')
      end

      it "should match on icmp:type8" do
        o.should match Checkpoint::Service::Matcher.new_s('icmp:type8')
        o.should_not match Checkpoint::Service::Matcher.new_s('icmp:type7')
      end

      it "should match on icmp:type8:code4" do
        o.should match Checkpoint::Service::Matcher.new_s('icmp:type8:code4')
        o.should_not match Checkpoint::Service::Matcher.new_s('icmp:type8:code5')
      end

      it "should match on :any" do
        o.should match Checkpoint::Service::Matcher.new_s('any')
      end

    end
  end

end
