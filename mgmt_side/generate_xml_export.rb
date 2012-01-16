#!/usr/bin/ruby
require 'pp'
require 'fileutils'
include FileUtils

# User and host config
user      = "cpmi_ro_user"
pass      = "cpmi_ro_user_password"
mgmthost  = "localhost"

# Where are our tools?
mybase    = "/usr/local/cpdb2xml_exports"
wiz_dir   = "/usr/local/Web_Visualization_Tool_R65.linux"

# Should not be changed. (hopefully)
outfile   = mybase + "/exports/cpdb2web_xml_#{Time.now.strftime("%Y%m%d_%H%M")}.tgz"
cpdb2web  = wiz_dir + "/cpdb2web"
tmp_dir   = mybase + "/tmp" + "/cpdb2web_" + Time.now.strftime("%Y%m%d_%H%M")

verbose = false
scripty = false
unless ARGV.grep("verbose").empty?
  verbose = true
end
unless ARGV.grep("scripty").empty?
  scripty = true
end

if File.exist?(outfile)
  puts "rm #{outfile}" if verbose
  rm outfile  
end
mkdir tmp_dir

export_cmd = ["source /etc/profile.d/CP.sh;"]
export_cmd += [cpdb2web, "-s", mgmthost, "-u", user, "-p", pass, "-o", tmp_dir]
export_cmd += ["1>/dev/null"] unless verbose
export_cmd = export_cmd.join(" ")
tgz_cmd="cd #{mybase+"/tmp"}; tar -zcf #{outfile} #{File.basename(tmp_dir)}"


log_export_cmd = export_cmd.gsub(/#{pass}/, "XXX")
begin
  puts log_export_cmd if verbose
  unless system(export_cmd)
    raise "cpdb export failed! code: #{$?.exitstatus}"
  end

  puts tgz_cmd if verbose
  unless system(tgz_cmd)
    raise "tgz create failed! code: #{$?.exitstatus}"
  else
    puts "scripty_outfile: #{outfile}" if scripty
  end
ensure
  if tmp_dir =~ /^#{mybase}/
    rm_rf tmp_dir
  else
    raise "tmp_dir (#{tmp_dir}) is not within by basedir (#{mybase})"
  end
end

exit 0
