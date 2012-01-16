require 'spec/spec_helper'

describe "Run script bin/cp_rule_test.rb" do
  let (:expected_output_xml) do
    File.read('spec/fixtures/cp_rule_test.out1')
  end

  let (:expected_output_mar) do
    File.read('spec/fixtures/cp_rule_test.out2')
  end

  let (:cmd) do
    %{printf "src 10.1.1.1 dst 10.1.1.2 srv tcp:22\nexit\n" | ruby -Ilib bin/cp_rule_test.rb spec/fixtures/Standard_Security_Policy.xml}
  end

  it "should give the expected output with xml file" do
    pending
    system("rm -f spec/fixtures/*.mar")
    output = `#{cmd}`
    output.should == expected_output_xml
  end

  it "should give the expected output with mar file" do
    pending
    system("rm -f spec/fixtures/*.mar")
    # create .mar cache first
    `#{cmd}`
    output = `#{cmd}`
    output.should == expected_output_mar
  end
end
