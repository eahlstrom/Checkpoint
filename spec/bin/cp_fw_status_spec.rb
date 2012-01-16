require 'spec/spec_helper'

describe "Run script bin/cp_fw_status.rb" do
  let (:expected_output) do
    File.read('spec/fixtures/cp_fw_status.out1')
  end

  let (:cmd) do
    %{ruby -Ilib bin/cp_fw_status.rb spec/fixtures}
  end

  it "should give the expected output with xml file" do
    output = `#{cmd}`
    output.should == expected_output
  end
end
