require 'spec/spec_helper'
require 'checkpoint/parse'

describe Checkpoint::Parse::ServicesXml do
  let(:file) { File.join(File.dirname(__FILE__), "/../../fixtures/services.xml") }

  it "should return an Hash with each service name as key" do
    s = Checkpoint::Parse::ServicesXml.file(file)
    s.should have(448).keys
    keys = s.keys
    keys.include?('ssh').should be_true
    keys.include?('telnet').should be_true
    keys.include?('CPD').should be_true
    keys.include?('Any').should be_true
    keys.include?('any').should be_true

    s['ssh'].keys.should =~ [
      :name, :comments, :type, :class_name,
      :include_in_any, :enable_tcp_resource, 
      :port, :proto_type_name
    ]
  end
end
