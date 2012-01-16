# Helper class to print out matching rules to console
#
# Sample usage is in bin/cp_rule_test.rb
#
class Checkpoint::Helpers::MatchPrinter
  COLOR = { :white  => "\033[01;29m",
            :grey   => "\033[01;30m",
            :red    => "\033[01;31m",
            :green  => "\033[01;32m",
            :yellow => "\033[01;33m",
            :blue   => "\033[01;34m",
            :purple => "\033[01;35m",
            :lblue  => "\033[01;36m",
            :normal => "\033[00m" }

  def initialize
  end

  def to_text(match_info, show_object_only=false)
    unless match_info.is_a? Hash
      raise ArgumentError, "Expected Hash got #{match_info.class}"
    end

    ljust_settings = {  "Rule#" => 7, "NAME" => 20, "SRC" => 60, "DST" => 60,
                        "SERVICE" => 35, "ACTION" => 10, "COMMENT" => 25, }

    out = COLOR[:grey]
    out += "Rule#".ljust(ljust_settings["Rule#"])
    out += "NAME".ljust(ljust_settings["NAME"])
    out += "SRC".ljust(ljust_settings["SRC"])
    out += "DST".ljust(ljust_settings["DST"])
    out += "SERVICE".ljust(ljust_settings["SERVICE"])
    out += "ACTION".ljust(ljust_settings["ACTION"])
    out += "COMMENT".ljust(ljust_settings["COMMENT"])
    len=0; ljust_settings.values.each {|v| len += v}
    out = COLOR[:grey] + "-"*(len+10) + "\n" + out
    out += "\n" + "-"*(len+10) + "\n"
    out += COLOR[:normal]

    match_info.keys.sort.each do |rule_no|
      ref = match_info[rule_no]

      out += COLOR[:grey] + "| "
      tmp = ""
      ljust_add = -2
      if ref[:action] =~ /accept/i
        tmp = COLOR[:green] + ref[:number] + COLOR[:normal]
        ljust_add += COLOR[:green].length + COLOR[:normal].length
      elsif ref[:action] =~ /(drop|reject)/
        tmp = COLOR[:red] + ref[:number] + COLOR[:normal]
        ljust_add += COLOR[:red].length + COLOR[:normal].length
      else
        tmp = ref[:number]
      end
      out += tmp.ljust(ljust_settings["Rule#"] + ljust_add)

      out += ref[:name].ljust(ljust_settings["NAME"])

      tmp = ""
      ljust_add = 0
      ref[:src].each_pair do |src, match|
        if match
          tmp += COLOR[:white] + src + " " + COLOR[:normal]
          ljust_add += COLOR[:white].length + COLOR[:normal].length
        else
          unless show_object_only
            tmp += COLOR[:normal] + src + " " + COLOR[:normal]
            ljust_add += COLOR[:normal].length + COLOR[:normal].length
          end
        end
      end
      out += tmp.ljust(ljust_settings["SRC"] + ljust_add)

      tmp = ""
      ljust_add = 0
      ref[:dst].each_pair do |dst, match|
        if match
          tmp += COLOR[:white] + dst + " " + COLOR[:normal]
          ljust_add += COLOR[:white].length + COLOR[:normal].length
        else
          unless show_object_only
            tmp += COLOR[:normal] + dst + " " + COLOR[:normal]
            ljust_add += COLOR[:normal].length + COLOR[:normal].length
          end
        end
      end
      out += tmp.ljust(ljust_settings["DST"] + ljust_add)

      tmp = ""
      ljust_add = 0
      ref[:service].each_pair do |srv, match|
        if match
          tmp += COLOR[:white] + srv + " " + COLOR[:normal]
          ljust_add += COLOR[:white].length + COLOR[:normal].length
        else
          unless show_object_only
            tmp += COLOR[:normal] + srv + " " + COLOR[:normal]
            ljust_add += COLOR[:normal].length + COLOR[:normal].length
          end
        end
      end
      out += tmp.ljust(ljust_settings["SERVICE"] + ljust_add)

      tmp_action = ""
      ljust_add = 0
      if ref[:action] =~ /accept/i
        tmp_action = COLOR[:green] + ref[:action] + COLOR[:normal]
        ljust_add += COLOR[:green].length + COLOR[:normal].length
      elsif ref[:action] =~ /(drop|reject)/i
        tmp_action = COLOR[:red] + ref[:action] + COLOR[:normal]
        ljust_add += COLOR[:red].length + COLOR[:normal].length
      else
        tmp_action = ref[:action]
      end
      out += tmp_action.ljust(ljust_settings["ACTION"] + ljust_add)

      out += ref[:comments].ljust(ljust_settings["COMMENT"])
      out += "\n"
    end
    len=0; ljust_settings.values.each {|v| len += v}
    out += COLOR[:grey]
    out += "" + "-"*(len+10) + "\n"
    out += COLOR[:normal]
    return out
  end
end
