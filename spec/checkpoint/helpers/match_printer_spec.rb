require 'spec/spec_helper'
require 'checkpoint/helpers'

describe Checkpoint::Helpers::MatchPrinter do
  it "should print out a colorized rules" do
    match_info = {
      12 => {
        :comments => "Permit ssh between all firewalls", 
        :number => "12", 
        :name => "", 
        :service => {"ssh"=>true}, 
        :src => {"src_host1"=>true, "src_host2"=>false}, 
        :dst => {"dst_host1"=>true, "dst_host2"=>false}, 
        :action => "drop"
    }}

    printer = Checkpoint::Helpers::MatchPrinter.new
    lambda {
      printer.to_text(match_info)
    }.should_not raise_error

    printer.to_text(match_info).should == File.read('spec/fixtures/match_printer_output.txt')
  end
end
