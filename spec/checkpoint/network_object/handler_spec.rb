require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject::Handler do
  describe "class methods" do
    describe "Checkpoint::NetworkObject::Handler.load_xml(file)" do
      it "should create a new instance from a xml file" do
        lambda {
          Checkpoint::NetworkObject::Handler.load_xml('spec/fixtures/network_objects.xml')
        }.should_not raise_error
      end
    end

    describe "Checkpoint::NetworkObject::Handler.load_mar(file)" do
      it "should create a new instance from a marshal dump file" do
        pending "need .mar file" unless File.exist? 'spec/fixtures/network_objects.mar'
        lambda {
          Checkpoint::NetworkObject::Handler.load_marshal('spec/fixtures/network_objects.mar')
        }.should_not raise_error
      end
    end

    describe "Checkpoint::NetworkObject::Handler.load(file)" do
      it "should create a new instance from a marshal dump file or xml file" do
        pending "need .mar file" unless File.exist? 'spec/fixtures/network_objects.mar'
        lambda {
          Checkpoint::NetworkObject::Handler.load('spec/fixtures/network_objects.mar')['host1'].name.should == "host1"
          Checkpoint::NetworkObject::Handler.load('spec/fixtures/network_objects.xml')['host1'].name.should == "host1"
        }.should_not raise_error
      end
    end
  end

  describe "instance methods" do
    let(:objects) {
      Checkpoint::NetworkObject::Handler.load('spec/fixtures/network_objects.xml')
    }

    it "should have easy access to 'name'" do
      objects['host1'].name.should == "host1"
    end
  end
end
