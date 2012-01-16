require 'spec/spec_helper'
require 'checkpoint/parse'

describe Checkpoint::Parse::RulebaseXml do
  let(:file) { File.join(File.dirname(__FILE__), "/../../fixtures/Standard_Security_Policy.xml") }

  it "should be able to parse rulebase" do
    rb = Checkpoint::Parse::RulebaseXml.file(file)
    rb.keys.should =~ [:class_name, :name, :rules]
    rb[:rules].should have(5).items
    r1 = rb[:rules].first
    r1['name'].should == 'allow ssh'
    r1['class_name'].should == 'security_rule'
    r1['rule_number'].should == '1'
    r1['comments'].should == ''
    r1['disabled'].should == 'false'
    r1['action'].should == 'accept'
    r1['track'].should == 'Log'
    r1['time'].should == 'Any'
    r1['install_on'].should == 'Any'
    r1['services'].should == ["ssh"]
    r1['src'].should == ["net_192.168.0.0-24"]
    r1['dst'].should == ["host1"]
  end
end
