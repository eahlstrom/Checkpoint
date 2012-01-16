#!/usr/bin/ruby
require 'fileutils'
$stdout.sync = true

mgmt_server_ssh = ARGV[0]
tmp_dir = File.dirname(__FILE__) + "/tmp"
cmd_on_mgmt = %{/usr/local/cpdb2xml_exports/scripts/generate_xml_export.rb verbose scripty}

unless mgmt_server_ssh
  puts "Usage: #{File.basename($0)} user@firewall-mgmt-server"
  puts "       user@firewall-mgmt-server -> ssh connect string"
  puts
  exit
end

remote_file = false
cmd = %{ssh #{mgmt_server_ssh} "#{cmd_on_mgmt}"}
puts cmd
File.popen(cmd).each_line do |line|
  line = line.chomp
  puts line
  if line =~ /^scripty_outfile:\s*(\S+)/
    remote_file = $1
  end
end

unless remote_file
  puts "ERROR: Cannot get remote filename! Remote error?"
  exit 1
end

cmd = "scp #{mgmt_server_ssh.strip}:#{remote_file} #{tmp_dir}"
if system(cmd)
  puts "cd #{tmp_dir}"  
  Dir.chdir(tmp_dir)
  cmd = "tar -xf #{File.basename(remote_file)}"
  puts cmd
  if system(cmd)
    system("rm #{File.basename(remote_file)}")
  else
    puts "ERROR: cmd failed!"
    exit 1
  end
else
  puts "ERROR: Command failed!"
  exit 1
end

puts
puts "Succesfully updated!"
outdir = File.basename(`ls -1rt`.split("\n").last)
puts %{Linking "latest" to #{outdir}}
system("rm -f latest")
system("ln -s #{outdir} latest")
puts "Files got into #{tmp_dir}/#{outdir}"
puts

