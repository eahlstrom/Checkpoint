require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service::Other do
  let(:hsh) do
    {
      :comments=>"", :type=>"other", :protocol=>"17", :class_name=>"other_service", :include_in_any=>"false", :name=>"other_obj", :exp=>"exp" 
    }
  end 

  it "should be possible to create instance" do
    lambda {
      udp_obj = Checkpoint::Service::Other.new(hsh)
    }.should_not raise_error
  end

  describe "instance" do
    let(:o) {Checkpoint::Service::Other.new(hsh)}

    it "should have accessor for name" do
      o.name.should == 'other_obj'
    end

    describe "matching" do
      it "should match object name" do
        o.should match Checkpoint::Service::Matcher.new_s('name:other_obj')
        o.should_not match Checkpoint::Service::Matcher.new_s('name:other')
      end

      it "should match on proto" do
        o.should match Checkpoint::Service::Matcher.new_s('proto:17')
        o.should_not match Checkpoint::Service::Matcher.new_s('proto:6')
      end

      it "should match on :any" do
        o.should match Checkpoint::Service::Matcher.new_s('any')
      end

    end
  end

end
