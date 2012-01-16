require 'spec/spec_helper'
require 'checkpoint/parse'

describe Checkpoint::Parse::NatRulebaseXml do
  let(:file) { File.join(File.dirname(__FILE__), "/../../fixtures/Standard_NAT_Policy.xml") }

  it "should be able to parse NAT rulebase" do
    rb = Checkpoint::Parse::NatRulebaseXml.file(file)
    rb.keys.should =~ [:class_name, :name, :rules_adtr]
    rb[:rules_adtr].should have(1).item
    rb[:rules_adtr][0].keys.should =~ [
      "name", "class_name", "rule_number", "comments", 
      "disabled", "install_on", "src_adtr_translated_method", 
      "dst_adtr_translated_method", "services_adtr", 
      "services_adtr_translated", "src_adtr", "src_adtr_translated", 
      "dst_adtr", "dst_adtr_translated"
    ]
  end
end
