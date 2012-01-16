#
# Class Responsible for parsing the network_objects.xml file
#
class Checkpoint::Parse::NetworkObjectsXml
  #
  # Converts network_objects.xml to an Hash
  #
  # *example*
  #
  #   Checkpoint::Parse::NetworkObjectsXml.file('spec/fixtures/network_objects.xml')
  #
  #   => {"AuxiliaryNet"=>{:name=>"AuxiliaryNet", :comments=>"", 
  #       :type=>"dynamic_net_obj", :class_name=>"dynamic_object", 
  #       :bogus_ip=>"3.4.1.0"}, ... }
  #
  def self.file(xml_file, verbose=false)
    skip_warnings = true
    doc = LibXML::XML::Document.file(xml_file)

    miss_class = Hash.new
    default_objects = %w{Name comments type Class_Name }
    get_obj = {
                "gateway_cluster" => default_objects + %w{ipaddr firewall __cluster_member_fetch__ __interface_fetch__},
                "cluster_member" => default_objects + %w{ipaddr Machine_weight __interface_fetch__},
                "gateway_ckp" => default_objects + %w{firewall ipaddr __interface_fetch__},
                "gateway_plain" => default_objects + %w{ipaddr __interface_fetch__ __fetch_encryption_domain__},
                "host_ckp" => default_objects + %w{ipaddr firewall management primary_management log_server __interface_fetch__},
                "host_plain" => default_objects + %w{ipaddr},
                "network" => default_objects + %w{ipaddr netmask},
                "network_object_group" => default_objects + %w{__grp_member_fetch__},
                "group_with_exception" => default_objects + %w{base/Name exception/Name},
                "address_range" => default_objects + %w{ipaddr_first ipaddr_last},
                "dynamic_object" => default_objects + %w{bogus_ip},
                "voip_GK_domain" => default_objects + %w{server/Name zone_range/Name h323_gatekeeper_protocols/h323_gatekeeper_protocols},
              }

    network_objects = Hash.new
    network_objects_by_type = Hash.new

    doc.find("//network_objects/network_object").each do |node|
      class_name = node.find_first("Class_Name").content

      unless get_obj.has_key?(class_name)
        miss_class[class_name] ||= 0
        miss_class[class_name] += 1
        next
      end

      net_obj = Hash.new
      puts "=== #{node.path} (#{class_name}) ===" if verbose
      get_obj[class_name].each do |obj|
        if obj == "__cluster_member_fetch__"
          puts "  Members                   - #{cluster_member_fetch(node).join(", ")}" if verbose
          net_obj[:cluster_members] = cluster_member_fetch(node)
        elsif obj == "__interface_fetch__"
          puts "  Num Interfaces            - #{interface_fetch(node).length}" if verbose
          net_obj[:interfaces] = interface_fetch(node)
        elsif obj == "__grp_member_fetch__"
          puts "  Num grp Members               - #{grp_member_fetch(node).length}" if verbose
          net_obj[:grp_members] = grp_member_fetch(node)
        elsif obj == "__fetch_encryption_domain__"
          puts "  ENC Domain                - #{fetch_encryption_domain(node)}" if verbose
          net_obj[:enc_domain] = fetch_encryption_domain(node)
        elsif obj =~ /^__\S+__$/
          puts "error: no method for: #{obj}" if verbose
          next
        else
          puts "  #{obj.ljust(25)} - #{node.find_first(obj).content}" if verbose
          obj_ref = node.find_first(obj)
          obj_str = ""
          if obj_ref.class == LibXML::XML::Node
            obj_str = obj_ref.content
          end
          if obj == "type"
            obj_str = obj_str.downcase
          end
          net_obj[obj.downcase.gsub(/\//, "_").to_sym] = obj_str
        end
      end
      if network_objects.has_key?(net_obj[:name])
        raise "#{net_obj[:name]} is already defined! Inconsistent XML file??"
      else
        unless net_obj.has_key?(:name)
          pp net_obj
          raise "Missing key --> :name <-- of object above."
        end
        network_objects[net_obj[:name]] = net_obj
        network_objects_by_type[class_name] ||= Array.new
        network_objects_by_type[class_name] << network_objects[net_obj[:name]]
      end
      puts if verbose
    end

    # Create link between objects.
    if network_objects_by_type.has_key?("gateway_cluster")
      network_objects_by_type["gateway_cluster"].each do |obj|
        tmp = Array.new
        obj[:cluster_members].each do |member|
          tmp << network_objects[member]
        end
        network_objects[obj[:name]][:cluster_members] = tmp
      end
    end

    if network_objects_by_type.has_key?("network_object_group")
      network_objects_by_type["network_object_group"].each do |obj|
        tmp = Array.new
        obj[:grp_members].each do |member|
          if network_objects[member].nil?
            near_object_name = network_objects.keys.grep(/^#{member}$/i).first
            # raise "member: #{member} has no reference in objects"
            unless skip_warnings
              $stderr.puts "WARNING: net_grp: #{obj[:name]}, member #{member} has no reference in objects, setting to nearest: #{near_object_name}"
            end
            tmp << network_objects[near_object_name]
          else
            tmp << network_objects[member]
          end
        end
        network_objects[obj[:name]][:grp_members] = tmp
      end
    end

    if network_objects_by_type.has_key?("voip_GK_domain")
      network_objects_by_type["voip_GK_domain"].each do |obj|
        [:server_name, :zone_range_name].each do |key|
          ref_object = network_objects[obj[key]]
          network_objects[obj[:name]][key] = ref_object
        end
      end
    end

    # Create the any object
    network_objects["Any"] = {:type => "any_type", :class_name => "any_type"}
    network_objects["any"] = network_objects["Any"]

    if network_objects_by_type.has_key?("group_with_exception")
      network_objects_by_type["group_with_exception"].each do |obj|
        [:base_name, :exception_name].each do |key|
          ref_object = network_objects[obj[key]]
          network_objects[obj[:name]][key] = ref_object
        end
      end
    end

    return network_objects
  end

  def self.grp_member_fetch(xml_node) # :nodoc:
    unless xml_node.class == LibXML::XML::Node
      raise ArgumentError, "invalid xml node" 
    end
    members = Array.new
    xml_node.find("members/reference").each do |m|
      members << m.find_first("Name").content 
    end
    return members
  end

  def self.cluster_member_fetch(xml_node) # :nodoc:
    unless xml_node.class == LibXML::XML::Node
      raise ArgumentError, "invalid xml node" 
    end
    members = Array.new
    xml_node.find("cluster_members/*").each do |m|
      members << m.find_first("Name").content
    end
    return members
  end

  def self.interface_fetch(xml_node) # :nodoc:
    tmp_ifs = Hash.new
    interfaces = Array.new
    unless xml_node.class == LibXML::XML::Node
      raise ArgumentError, "invalid xml node" 
    end
    xml_node.find("interfaces/*").each do |i_f|
      ifindex = i_f.find_first("ifindex").content.to_i
      tmp_ifs[ifindex] = Hash.new
      %w{ipaddr netmask officialname}.each do |key|
        tmp_ifs[ifindex][key] = i_f.find_first(key).content
      end
    end
    tmp_ifs.keys.sort.each do |key|
      interfaces << tmp_ifs[key]
    end
    return interfaces
  end

  def self.fetch_encryption_domain(xml_node) # :nodoc:
    unless xml_node.class == LibXML::XML::Node
      raise ArgumentError, "invalid xml node" 
    end
    enc_dom = xml_node.find_first("manual_encdomain/Name")
    if enc_dom.class == LibXML::XML::Node
      return enc_dom.content
    else
      return ""
    end
  end
end
