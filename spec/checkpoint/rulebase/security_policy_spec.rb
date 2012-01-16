require 'spec/spec_helper'
require 'checkpoint'

describe Checkpoint::Rulebase::SecurityPolicy do
  let(:raw_rulebase) do
    Checkpoint::Parse::RulebaseXml.file(File.join(File.dirname(__FILE__), "/../../fixtures/Standard_Security_Policy.xml"))
  end
  let(:raw_services) do
    Checkpoint::Parse::ServicesXml.file(File.join(File.dirname(__FILE__), "/../../fixtures/services.xml"))
  end
  let(:nw_objects) do
    Checkpoint::NetworkObject::Handler.load(File.join(File.dirname(__FILE__), "/../../fixtures/network_objects.xml"))
  end

  it "should load a rulebase" do
    lambda {
      Checkpoint::Rulebase::SecurityPolicy.new(raw_rulebase, nw_objects, raw_services)
    }.should_not raise_error
  end

  describe "simulating" do
    let(:rb) { Checkpoint::Rulebase::SecurityPolicy.new(raw_rulebase, nw_objects, raw_services) }

    it "should return rule 2 when: 10.10.11.15 => 192.168.0.100 tcp:22" do
      rules = rb.simulate_packet(
        Checkpoint::NetworkObject::Matcher.new_s("10.10.11.15"),
        Checkpoint::NetworkObject::Matcher.new_s("192.168.0.100"),
        Checkpoint::Service::Matcher.new_s("tcp:22"),
        :return_at_first_match => true
      )
      rules.keys.should == [2]
      rules[2].should == {
        :number=>"2",
        :name=>"hq",
        :comments=>"",
        :action=>"accept",
        :src=>{"net_192.168.0.0-24"=>false, "net_10.10.11.0-24"=>true},
        :dst=>{"net_10.10.11.0-24"=>false, "net_192.168.0.0-24"=>true},
        :service=>{"Any"=>true}
      }
    end

    it "should return rule 5 when: 1.1.1.1 => 2.2.2.2 udp:65001" do
      rules = rb.simulate_packet(
        Checkpoint::NetworkObject::Matcher.new_s("1.1.1.1"),
        Checkpoint::NetworkObject::Matcher.new_s("2.2.2.2"),
        Checkpoint::Service::Matcher.new_s("udp:65001"),
        :return_at_first_match => true
      )
      rules.keys.should == [5]
      rules[5].should == {
        :number=>"5",
        :name=>"",
        :comments=>"",
        :action=>"drop",
        :src=>{"Any"=>true},
        :dst=>{"Any"=>true},
        :service=>{"Any"=>true}
      }
    end
  end
end
