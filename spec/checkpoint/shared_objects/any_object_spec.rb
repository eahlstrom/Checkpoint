require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::SharedObjects::AnyObject do
  let(:hsh) do
    {:type => "any_type"}
  end

  it "should be possible to create instance" do
    lambda {
      udp_obj = Checkpoint::SharedObjects::AnyObject.new(hsh)
    }.should_not raise_error
  end

  describe "instance" do
    let(:o) {Checkpoint::SharedObjects::AnyObject.new(hsh)}

    it "should have accessor for name" do
      o.name.should == 'Any'
    end

    describe "matching" do
      it "should always match" do
        o.should match Checkpoint::Service::Matcher.new_s('name:echo-request')
        o.should match Checkpoint::Service::Matcher.new_s('tcp:22')
        o.should match Checkpoint::Service::Matcher.new_s('udp:139')
      end
    end
  end

end
