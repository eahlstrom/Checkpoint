require 'spec/spec_helper'

describe "Run script cp_clusterIP2hostsfile.rb" do
  let (:expected_output) do
    File.read('spec/fixtures/cp_clusterIP2hostsfile.out1')
  end

  it "should give the expected output with xml file" do
    pending
    output = `ruby -Ilib bin/cp_clusterIP2hostsfile.rb spec/fixtures/network_objects.xml`
    output.gsub(/at\s+.*/, "").should == expected_output.gsub(/at\s+.*/, "")
  end

  it "should give the expected output with mar file" do
    pending "need mar cache files in spec/fixtures" unless File.exist? "spec/fixtures/network_objects.mar"
    output = `ruby -Ilib bin/cp_clusterIP2hostsfile.rb spec/fixtures/network_objects.mar`
    output.gsub(/at\s+.*/, "").should == expected_output.gsub(/at\s+.*/, "")
  end
end
