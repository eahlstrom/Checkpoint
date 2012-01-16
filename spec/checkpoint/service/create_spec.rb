require 'spec/spec_helper'
require 'checkpoint/service'

describe Checkpoint::Service do
  describe "Factory" do
    Checkpoint::Service::CLASS_FOR_TYPE.each_pair do |type, klass|
      if klass == :skip
        it "should skip create object when :type == \"#{type}\"" do
          Checkpoint::Service.create(:type=>type).should be_false
        end
      else
        it "should create #{klass} object when :type == \"#{type}\"" do
          klass.should_receive(:new).with(:type=>type)
          Checkpoint::Service.create(:type=>type)
        end
      end
    end
  end
end
