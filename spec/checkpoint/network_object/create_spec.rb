require 'spec/spec_helper'
require 'checkpoint/network_object'

describe Checkpoint::NetworkObject do
  describe "Factory" do
    Checkpoint::NetworkObject::CLASS_FOR_TYPE.each_pair do |class_name, klass|
      it "should create #{klass} object when :class_name == \"#{class_name}\"" do
        klass.should_receive(:new).with(:class_name=>class_name)
        Checkpoint::NetworkObject.create(:class_name=>class_name)
      end
    end
  end
end
