require 'spec/spec_helper'
require 'checkpoint/helpers'

describe Checkpoint::Helpers::IP do
  before(:each) do
    extend Checkpoint::Helpers::IP
  end

  it "should check our ipaddress for validity" do
    valid_ipv4?("10.1.1.1").should be_true
    valid_ipv4?("10.1.1.256").should be_false
    valid_ipv4_cidr?("10.1.1.1/24").should be_true
    valid_ipv4_cidr?("10.1.1.256/33").should be_false
    valid_ipv4_ipnetmask?("10.1.1.0/255.255.255.0").should be_true
    valid_ipv4_ipnetmask?("10.1.1.256/255.255.255.256").should be_false
  end
end
