class Checkpoint::Parse::NatRulebaseXml
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
    rulebase[:rules_adtr] = Array.new

    doc.find("//fw_policies/fw_policie/rule_adtr/*").each do |node|
      header_text = node.find_first("header_text")
      if header_text.class == LibXML::XML::Node
        rulebase[:rules_adtr] << { :header_text => header_text.content }
        next
      end

      class_name = node.find_first("Class_Name")
      if class_name.class == LibXML::XML::Node
        unless class_name.content == "address_translation_rule"
          raise "unknown(#{class_name.content}) security rule"
        end
      else
        raise "rule without: Class_Name"
      end

      rule = Hash.new
      %w{Name Class_Name Rule_Number comments disabled}.each do |ref|
        tmp_object = node.find_first(ref)
        tmp_str = ""
        if tmp_object.class == LibXML::XML::Node
          tmp_str = tmp_object.content
        end
        rule[ref.downcase] = tmp_str
      end

      rule["install_on"] = node.find_first("install/install/Name").content
      rule["src_adtr_translated_method"] = node.find_first("src_adtr_translated/adtr_method").content
      rule["dst_adtr_translated_method"] = node.find_first("dst_adtr_translated/adtr_method").content
      rule["install_on"] = node.find_first("install/install/Name").content

      rule["services_adtr"] = Array.new
      node.find("services_adtr/services_adtr/Name").each do |n|
        rule["services_adtr"] << n.content
      end
      rule["services_adtr_translated"] = Array.new
      node.find("services_adtr_translated/reference/Name").each do |n|
        rule["services_adtr_translated"] << n.content
      end

      rule["src_adtr"] = Array.new
      node.find("src_adtr/src_adtr/Name").each do |n|
        rule["src_adtr"] << n.content
      end
      rule["src_adtr_translated"] = Array.new
      node.find("src_adtr_translated/reference/Name").each do |n|
        rule["src_adtr_translated"] << n.content
      end
      rule["dst_adtr"] = Array.new
      node.find("dst_adtr/dst_adtr/Name").each do |n|
        rule["dst_adtr"] << n.content
      end
      rule["dst_adtr_translated"] = Array.new
      node.find("dst_adtr_translated/reference/Name").each do |n|
        rule["dst_adtr_translated"] << n.content
      end

      rulebase[:rules_adtr] << rule
    end
    return rulebase
  end
end
