require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service::TCPport do
  let(:hsh) {
    {:comments=>"", :type=>"tcp", :enable_tcp_resource => "false", :class_name=>"tcp_service", :include_in_any=>"true", :name=>"tcp_1234", :proto_type_name=>"", :port=>"1234"}
  }

  it "should be possible to create instance" do
    lambda {
      tcp_obj = Checkpoint::Service::TCPport.new(hsh)
    }.should_not raise_error
  end

  describe "instance" do
    let(:tcp) {Checkpoint::Service::TCPport.new(hsh)}

    it "should have accessor for name" do
      tcp.name.should == 'tcp_1234'
    end

    describe "matching" do
      it "should match object name" do
        match     = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => 'tcp_1234')
        no_match  = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => 'tcp_4321')
        tcp.should match(match)
        tcp.should_not match(no_match)
      end

      it "should match protocol" do
        match     = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 6, :port => 1234, :end_port => nil)
        no_match  = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 17, :port => 1234, :end_port => nil)
        tcp.should match(match)
        tcp.should_not match(no_match)
      end

      it "should match port" do
        match     = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 6, :port => 1234, :end_port => nil)
        no_match  = mock(Checkpoint::Service::Matcher, :is_a? => true, :object_name => nil, :type => nil, :proto => 6, :port => 1235, :end_port => nil)
        tcp.should match(match)
        tcp.should_not match(no_match)
      end

      it "should match range" do
        tcp.should match Checkpoint::Service::Matcher.new_s("tcp:1000-2000")
        tcp.should_not match Checkpoint::Service::Matcher.new_s("tcp:4000-5000")
      end
    end
  end

end
