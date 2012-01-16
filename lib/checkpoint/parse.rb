module Checkpoint
  # namespace'ing module for all XML parsing
  #
  module Parse
  end
end

require 'xml/libxml'

require 'checkpoint/parse/network_objects_xml'
require 'checkpoint/parse/services_xml'
require 'checkpoint/parse/rulebase_xml'
require 'checkpoint/parse/nat_rulebase_xml'

