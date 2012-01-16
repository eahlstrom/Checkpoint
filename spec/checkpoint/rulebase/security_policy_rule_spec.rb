require 'spec/spec_helper'
require 'checkpoint'

describe Checkpoint::Rulebase::SecurityPolicyRule do
  let(:raw_rulebase) do
    Checkpoint::Parse::RulebaseXml.file(File.join(File.dirname(__FILE__), "/../../fixtures/Standard_Security_Policy.xml"))
  end
  let(:raw_services) do
    Checkpoint::Parse::ServicesXml.file(File.join(File.dirname(__FILE__), "/../../fixtures/services.xml"))
  end
  let(:nw_objects) do
    Checkpoint::NetworkObject::Handler.load(File.join(File.dirname(__FILE__), "/../../fixtures/network_objects.xml"))
  end

  it "should load a rule" do
    r1_hsh = raw_rulebase[:rules][0]
    r1 = Checkpoint::Rulebase::SecurityPolicyRule.new(r1_hsh, nw_objects, raw_services)
  end

  describe "simulating" do
    let(:r1) { Checkpoint::Rulebase::SecurityPolicyRule.new(raw_rulebase[:rules][0], nw_objects, raw_services) }

    it "rule 1 should match 192.168.0.10 => 10.10.10.10 tcp:22" do
      result, match_rule = r1.match(
        Checkpoint::NetworkObject::Matcher.new_s("192.168.0.10"),
        Checkpoint::NetworkObject::Matcher.new_s("10.10.10.10"),
        Checkpoint::Service::Matcher.new_s("tcp:22"),
        :debug => false
      )
      result.should be_true
      match_rule.should == {
        :number=>"1", :name=>"allow ssh", :comments=>"", :action=>"accept", 
        :src=>{"net_192.168.0.0-24"=>true}, :dst=>{"host1"=>true}, :service=>{"ssh"=>true}
      }
    end

    it "rule 1 should not match 192.168.0.10 => 10.10.10.10 tcp:21" do
      result, match_rule = r1.match(
        Checkpoint::NetworkObject::Matcher.new_s("192.168.0.10"),
        Checkpoint::NetworkObject::Matcher.new_s("10.10.10.10"),
        Checkpoint::Service::Matcher.new_s("tcp:21"),
        :debug => false
      )
      result.should be_false
      match_rule.should == {
        :number=>"1", :name=>"allow ssh", :comments=>"", :action=>"accept", 
        :src=>{"net_192.168.0.0-24"=>true}, :dst=>{"host1"=>true}, :service=>{"ssh"=>false}
      }
    end

    it "rule 1 should not match 192.168.0.10 => 10.10.10.11 tcp:22" do
      result, match_rule = r1.match(
        Checkpoint::NetworkObject::Matcher.new_s("192.168.0.10"),
        Checkpoint::NetworkObject::Matcher.new_s("10.10.10.11"),
        Checkpoint::Service::Matcher.new_s("tcp:22"),
        :debug => false
      )
      result.should be_false
      match_rule.should == {
        :number=>"1", :name=>"allow ssh", :comments=>"", :action=>"accept", 
        :src=>{"net_192.168.0.0-24"=>true}, :dst=>{"host1"=>false}
      }
    end
  end
end
