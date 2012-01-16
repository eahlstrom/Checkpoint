#!/usr/bin/ruby

require 'rubygems'
require 'checkpoint'
require 'readline'

$stdout.sync
(rulebase_file, network_objects_file, service_objects_file) = ARGV

unless rulebase_file
  puts "Usage: #{File.basename(__FILE__)} rulebase [network_objects] [service_objects]"
  exit
end
rulebase_dir = File.dirname(rulebase_file)

unless network_objects_file
  if File.exist?(rulebase_dir + "/network_objects.mar")
    network_objects_file = rulebase_dir + "/network_objects.mar"
  elsif File.exist?(rulebase_dir + "/network_objects.xml")
    network_objects_file = rulebase_dir + "/network_objects.xml"
  else
    raise "No network_objects.xml or .mar file in directory: #{rulebase_dir}"
  end
end
unless service_objects_file
  if File.exist?(rulebase_dir + "/services.mar")
    service_objects_file = rulebase_dir + "/services.mar"
  elsif File.exist?(rulebase_dir + "/services.xml")
    service_objects_file = rulebase_dir + "/services.xml"
  else
    raise "No services.xml or .mar file in directory: #{rulebase_dir}"
  end
end



help_msg = <<END_TEXT

  Usage: 
  src NET_MATCH_OBJECT dst NET_MATCH_OBJECT srv SERVICE_MATCH_OBJECT [all show_object_only]

  NET_MATCH_OBJECT     => 192.168.1.1 | 192.168.1.0/24 | name:host_10.1.1.1 | any
  SERVICE_MATCH_OBJECT => tcp:22 tcp:22-50 udp:53 icmp proto:17 name:ssh | any
  all                  => Don't stop at first matching rule.
  show_object_only     => Show only matching object in output.

  examples:
    src 10.1.1.1 dst 10.1.1.2 srv tcp:22
    src 10.1.1.1 dst name:host_10.1.1.2 srv name:ssh
    
  Rulebase loaded: #{File.basename(rulebase_file)}

END_TEXT

puts "Loading rulebase_file -> #{rulebase_file.inspect}"
puts "Loading network_objects_file  -> #{network_objects_file.inspect}"
puts "Loading service_objects_file  -> #{service_objects_file.inspect}"
print "-"*50, "\n", help_msg, "\n", "-"*50,"\n\nLoading...\n"

rulebase_cache = rulebase_file.gsub(/xml$/, 'mar')
if File.exist?(rulebase_cache)
  rulebase = Marshal.load(File.read(rulebase_cache))
else
  rulebase = Checkpoint::Parse::RulebaseXml.file(rulebase_file)
  puts "cache rulebase..."
  File.open(rulebase_cache, "w") {|f| f.print Marshal.dump(rulebase)}
end

network_objects = Checkpoint::NetworkObject::Handler.load(network_objects_file)
network_objects_cache = network_objects_file.gsub(/xml$/, 'mar')
unless File.exist?(network_objects_cache)
  File.open(network_objects_cache, "w") {|f| f.print Marshal.dump(network_objects)}
  puts "cache network_objects..."
end

service_objects_cache = service_objects_file.gsub(/xml$/, 'mar')
if File.exist?(service_objects_cache)
  service_objects = Marshal.load(File.read(service_objects_cache))
else
  service_objects = Checkpoint::Parse::ServicesXml.file(service_objects_file)
  puts "cache service_objects..."
  File.open(service_objects_cache, "w") {|f| f.print Marshal.dump(service_objects)}
end


printer = Checkpoint::Helpers::MatchPrinter.new
rb = Checkpoint::Rulebase::SecurityPolicy.new(rulebase, network_objects, service_objects)

prev_line = ""
prompt = "#{rb.name}> "
history = Array.new
loop do 
  cmd = Readline::readline(prompt, history)
  exit if cmd =~ /quit|exit/i
  (src, dst, tcp_port, udp_port, show_object_only) = false
  return_at_first = true
  srcs = $1 if cmd =~ /src\s+(\S+)/i
  dsts = $1 if cmd =~ /dst\s+(\S+)/i
  srvs = $1 if cmd =~ /\s+srv\s+(\S+)/i
  show_object_only = true if cmd =~ /\s+show_object_only/
  return_at_first = false if cmd =~ /\s+all\s*/

  if cmd =~ /help/i
    puts help_msg
    next
  end

  if cmd =~ /^(.*)\\\s*$/
    prev_line += $1
    next
  else
    cmd = prev_line + " " + cmd
    prev_line = ""
  end
  cmd = prev_line + " " + cmd

  unless srcs
    puts "miss src" 
    next
  end
  unless dsts
    puts "miss dst" 
    next
  end
  unless srvs
    puts "miss srv"
    next
  end
  
  srcs.split(",").each do |src|
    dsts.split(",").each do |dst|
      srvs.split(",").each do |srv|
        # puts "src #{src_obj} dst #{dst_obj} srv #{srv_obj}"
        begin
          srv_obj = Checkpoint::Service::Matcher.new_s(srv)
        rescue ArgumentError
          puts "srv format error"
          next
        end

        begin
          src_obj = Checkpoint::NetworkObject::Matcher.new_s(src)
          dst_obj = Checkpoint::NetworkObject::Matcher.new_s(dst)
          if src_obj.type == :netobject_name
            unless network_objects.object_exist?(src_obj.netobject_name)
              puts "non-existing object: \"#{src_obj.netobject_name}\""
              next
            end
          end
          if dst_obj.type == :netobject_name
            unless network_objects.object_exist?(dst_obj.netobject_name)
              puts "non-existing object: \"#{dst_obj.netobject_name}\""
              next
            end
          end
        rescue ArgumentError
          puts "src/dst format error"
          next
        end
        puts
        puts "Testing: src #{src} dst #{dst} srv #{srv}"
        match_info = rb.simulate_packet(src_obj, dst_obj, srv_obj, {:return_at_first_match => return_at_first})
        printer.to_text(match_info, show_object_only).each_line do |line|
          puts "  #{line}"
        end
        puts
      end
    end
  end
end 

