require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service::UDPport do
  let(:hsh) {
    {:comments=>"", :type=>"udp", :class_name=>"udp_service", :include_in_any=>"true", :name=>"udp_1234", :proto_type_name=>"", :port=>"1234"}
  }

  it "should be possible to create instance" do
    lambda {
      udp_obj = Checkpoint::Service::UDPport.new(hsh)
    }.should_not raise_error
  end

  describe "instance" do
    let(:udp) {Checkpoint::Service::UDPport.new(hsh)}

    it "should have accessor for name" do
      udp.name.should == 'udp_1234'
    end

    describe "matching" do
      it "should match object name" do
        match     = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => 'udp_1234')
        no_match  = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => 'udp_4321')
        udp.should match(match)
        udp.should_not match(no_match)
      end

      it "should match protocol" do
        match     = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 17, :port => 1234, :end_port => nil)
        no_match  = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 6, :port => 1234, :end_port => nil)
        udp.should match(match)
        udp.should_not match(no_match)
      end

      it "should match port" do
        match     = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 17, :port => 1234, :end_port => nil)
        no_match  = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 17, :port => 1235, :end_port => nil)
        udp.should match(match)
        udp.should_not match(no_match)
      end

      it "should match on any" do
        udp.should match Checkpoint::Service::Matcher.new_s("any")
      end

      it "should match range" do
        match = Checkpoint::Service::Matcher.new_s("udp:1000-2000")
        no_match = Checkpoint::Service::Matcher.new_s("udp:4000-5000")
        udp.should match(match)
        udp.should_not match(no_match)
      end
    end
  end

end
