#!/usr/bin/env ruby

require 'rubygems'
require 'checkpoint'
require 'readline'
require 'optparse'

# default options
options = {
  :verbose        => false,
  :quiet          => false,
  :help           => false,
}

$opt_parse = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} {opts} XML-Export-Directory {XML-Export-Directory ...} "
  opts.on("-v", "--verbose", "Show more details.")  {|v| options[:verbose] = v}
  opts.on("-q", "--quiet", "Dont print any details.")  {|v| options[:quiet] = v}
  opts.on("-?", "--help", "Show this help message.")  {|v| options[:help] = v}
end
begin
  $opt_parse.parse!
rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
  print e, "\n\n", $opt_parse.help, "\n"
  exit 1
end
if options[:help]
  puts $opt_parse.help
  exit 0
end

def show_usage(msg="")
  $stderr.print msg, "\n\n" unless msg.empty?
  $stderr.puts $opt_parse.help
  exit 1
end

$stdout.sync

xml_export_dirs = ARGV
show_usage if ARGV.empty?
object_statuses = Array.new

xml_export_dirs.each do |xml_export_dir|
  show_usage unless File.exist?(xml_export_dir.to_s)
  show_usage unless File.directory?(xml_export_dir)

  network_objects_file = File.join(xml_export_dir, "network_objects.xml")
  service_objects_file = File.join(xml_export_dir, "services.xml")
  show_usage("No network_objects.xml file, correct dir?") unless File.exist?(network_objects_file.to_s)
  show_usage("No services.xml file, correct dir?") unless File.exist?(service_objects_file.to_s)

  security_policies = []
  Dir.glob(xml_export_dir + "/*_Security_Policy.xml").each do |file|
    security_policies << file.chomp
  end

  object_status = Hash.new
  network_objects = Checkpoint::NetworkObject::Handler.load(network_objects_file)
  object_status[:network_objects] = Hash.new
  network_objects.objects.each_pair do |objname, object|
    object_status[:network_objects][:total] ||= 0
    object_status[:network_objects][object.class.to_s] ||= 0
    object_status[:network_objects][:total] += 1
    object_status[:network_objects][object.class.to_s] += 1
  end

  service_objects = Checkpoint::Parse::ServicesXml.file(service_objects_file)
  object_status[:services] = Hash.new
  service_objects.each_pair do |objname, object|
    if object[:class_name]
      object_status[:services][:total] ||= 0
      object_status[:services][:total] += 1
      object_status[:services][object[:class_name]] ||= 0
      object_status[:services][object[:class_name]] += 1
    end
  end

  object_status[:security_policies] = Hash.new
  object_status[:security_policies][:total] = 0
  security_policies.each do |policy_file|
    policy = Checkpoint::Parse::RulebaseXml.file(policy_file)
    if policy[:name]
      object_status[:security_policies][policy[:name]] = Hash.new
      object_status[:security_policies][policy[:name]][:total] = 0
      object_status[:security_policies][policy[:name]][:enabled] = 0
      object_status[:security_policies][policy[:name]][:disabled] = 0
      object_status[:security_policies][policy[:name]][:headers] = 0

      policy[:rules].each do |rule|
        if rule.has_key?("header_text")
          object_status[:security_policies][policy[:name]][:headers] += 1
          next
        end
        object_status[:security_policies][:total] += 1
        object_status[:security_policies][policy[:name]][:total] += 1
        if rule["disabled"] =~ /false/i
          object_status[:security_policies][policy[:name]][:enabled] += 1
        else
          object_status[:security_policies][policy[:name]][:disabled] += 1
        end
      end
    end
    policy = nil
  end

  object_statuses << {:dir => xml_export_dir}.merge(object_status)

  print "==== #{File.basename(xml_export_dir)} ===\n"
  print "  Network objects:".ljust(45), " -> ", object_status[:network_objects][:total], "\n"
  unless options[:quiet]
    (object_status[:network_objects].sort {|a,b| a[1] <=> b[1]}).reverse.each do |obj|
      next if obj[0] == :total
      puts "    #{obj[0].to_s.ljust(45)} -> #{obj[1]}"
    end
    puts
  end

  print "  Services:".ljust(45), " -> ", object_status[:services][:total], "\n"
  unless options[:quiet]
    (object_status[:services].sort {|a,b| a[1] <=> b[1]}).reverse.each do |obj|
      next if obj[0] == :total
      puts "    #{obj[0].to_s.ljust(45)} -> #{obj[1]}"
    end
    puts
  end


  print "  Rules:".ljust(45), " -> ", object_status[:security_policies][:total], "\n"
  unless options[:quiet]
    ((object_status[:security_policies].collect {|k,v| [k,v[:total]] if v.is_a?(Hash)}.compact).sort {|a,b| b[1] <=> a[1]}).each do |arr_obj|
      policy = arr_obj[0]
      ref = object_status[:security_policies][policy]
      next if policy == :total
      puts "    #{policy.ljust(45)} -> #{object_status[:security_policies][policy][:total]}"
      if options[:verbose]
        (object_status[:security_policies][policy].sort {|a,b| a[1] <=> b[1]}).reverse.each do |obj|
          next if obj[0] == :total
          next if obj[0] == :headers
          puts "      #{obj[0].to_s.ljust(45)} -> #{obj[1]}"
        end
      end
    end
  end
  puts
end
