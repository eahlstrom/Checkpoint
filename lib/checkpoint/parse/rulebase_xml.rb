class Checkpoint::Parse::RulebaseXml
  def self.file(xml_file)
    doc = LibXML::XML::Document.file(xml_file)

    class_name = doc.find_first("//fw_policies/fw_policie/Class_Name")

    if (class_name.class != LibXML::XML::Node) or (class_name.content != "firewall_policy")
      raise %{XML file is not a security policy (Class_Name != "firewall_policy"} 
    else
      class_name = class_name.content
    end

    rulebase = Hash.new
    rulebase[:class_name] = class_name
    rulebase[:name] = doc.find_first("//fw_policies/fw_policie/collection/Name").content
    rulebase[:rules] = Array.new

    doc.find("//fw_policies/fw_policie/rule/*").each do |node|
      header_text = node.find_first("header_text")
      if header_text.class == LibXML::XML::Node
        rulebase[:rules] << { "header_text" => header_text.content }
        next
      end

      class_name = node.find_first("Class_Name")
      if class_name.class == LibXML::XML::Node
        unless class_name.content == "security_rule"
          raise "unknown(#{class_name.content}) security rule"
        end
      else
        raise "rule without: Class_Name"
      end

      rule = Hash.new
      %w{name Class_Name Rule_Number comments disabled}.each do |ref|
        tmp_object = node.find_first(ref)
        tmp_str = ""
        if tmp_object.class == LibXML::XML::Node
          tmp_str = tmp_object.content
        end
        rule[ref.downcase] = tmp_str
      end

      rule["action"] = node.find_first("action/action/Name").content
      rule["track"] = node.find_first("track/track/Name").content
      rule["time"] = node.find_first("time/time/Name").content
      rule["install_on"] = node.find_first("install/members/reference/Name").content

      rule["services"] = Array.new
      node.find("services/members/reference/Name").each do |n|
        rule["services"] << n.content
      end

      rule["src"] = Array.new
      node.find("src/members/reference/Name").each do |n|
        rule["src"] << n.content
      end

      rule["dst"] = Array.new
      node.find("dst/members/reference/Name").each do |n|
        rule["dst"] << n.content
      end

      rulebase[:rules] << rule
    end
    return rulebase
  end
end
