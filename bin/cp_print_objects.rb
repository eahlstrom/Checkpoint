#!/usr/bin/env ruby

require 'rubygems'
require 'checkpoint/network_object'

$stdout.sync
network_objects_file = ARGV[0]

unless network_objects_file
  puts "Usage: #{File.basename(__FILE__)} [NETWORK_OBJECTS_FILE] {ObjectGroup}"
  puts "  ObjectGroup in: Group Host Network... (default: Group)"
  exit
end

network_objects = Checkpoint::NetworkObject::Handler.load(network_objects_file)

match_obj_type = ARGV[1] || "Group"
p match_obj_type
network_objects.print_objects(:class_name_regexp => /#{match_obj_type}/)

