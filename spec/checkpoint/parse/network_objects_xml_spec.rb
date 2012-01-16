require 'spec/spec_helper'
require 'checkpoint/parse'

describe Checkpoint::Parse::NetworkObjectsXml do
  let(:nw_objects_file) { File.join(File.dirname(__FILE__), "/../../fixtures/network_objects.xml") }

  describe "self.file(net_objects_file)" do
    it "should return an Hash with each objects name as keys" do
      parsed = Checkpoint::Parse::NetworkObjectsXml.file(nw_objects_file, false)
      parsed.keys.should =~ %w{ 
        AuxiliaryNet CPDShield DMZNet InternalNet LocalMachine 
        LocalMachine_All_Interfaces group1 excl_grp1 cpmodule 
        host1 net_10.10.11.0-24 net_192.168.0.0-24 Any any
      }
    end
  end

end
