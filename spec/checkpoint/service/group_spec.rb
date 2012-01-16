require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service::Group do
  let(:hsh) do
    {
      :type=>"group", :include_in_any=>"", :name=>"srv_group", 
      :grp_members=> [
        {:type=>"udp", :include_in_any=>"false", :proto_type_name=>"", :name=>"u23", :port=>"23", :comments=>"", :class_name=>"udp_service"},
        {:type=>"tcp", :include_in_any=>"false", :proto_type_name=>"", :name=>"t22", :port=>"22", :comments=>"", :enable_tcp_resource=>"false", :class_name=>"tcp_service"}
      ],
      :comments=>"", :class_name=>"service_group" 
    }
  end 

  it "should be possible to create instance" do
    lambda {
      udp_obj = Checkpoint::Service::Group.new(hsh)
    }.should_not raise_error
  end

  describe "instance" do
    let(:o) {Checkpoint::Service::Group.new(hsh)}

    it "should have accessor for name" do
      o.name.should == 'srv_group'
    end

    describe "matching" do
      it "should match object name" do
        o.should match Checkpoint::Service::Matcher.new_s('name:srv_group')
        o.should_not match Checkpoint::Service::Matcher.new_s('name:other_group')
      end

      it "should do matching on the members" do
        matcher = Checkpoint::Service::Matcher.new_s('tcp:22')
        members = o.instance_eval('@members')
        members[0].should_receive(:match).with(matcher).and_return(false)
        members[1].should_receive(:match).with(matcher).and_return(true)
        o.match matcher
        o.last_matching_member.should == members[1].name
      end

      it "should save last matching members name" do
        matcher = Checkpoint::Service::Matcher.new_s('tcp:22')
        members = o.instance_eval('@members')
        members[0].stub(:match).with(matcher).and_return(false)
        members[1].stub(:match).with(matcher).and_return(true)
        o.match matcher
        o.last_matching_member.should == members[1].name
      end

    end
  end

end
