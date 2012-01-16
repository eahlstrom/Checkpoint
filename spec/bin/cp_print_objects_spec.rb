require 'spec/spec_helper'

describe "Run script bin/cp_print_objects.rb" do
  let (:expected_output) do
    File.read('spec/fixtures/cp_print_objects.out1')
  end

  it "should give the expected output with xml file" do
    pending
    output = `ruby -Ilib bin/cp_print_objects.rb spec/fixtures/network_objects.xml 2>&1`
    output.should == expected_output
  end

  it "should give the expected output with mar file" do
    pending
    output = `ruby -Ilib bin/cp_print_objects.rb spec/fixtures/network_objects.mar 2>&1`
    output.should == expected_output
  end
end
