class Checkpoint::Parse::ServicesXml
  def self.file(xml_file, verbose=false)
    doc = LibXML::XML::Document.file(xml_file)

    miss_class = Hash.new
    default_objects = %w{Name comments type Class_Name include_in_any }
    get_obj = {
                "tcp_service" => default_objects + %w{enable_tcp_resource port proto_type/Name},
                "udp_service" => default_objects + %w{port proto_type/Name},
                "service_group" => default_objects + %w{__grp_member_fetch__},
                "dcerpc_service" => default_objects + %w{uuid},
                "gtp_v1_service" => default_objects + %w{},
                "gtp_service" => default_objects + %w{},
                "gtp_mm_v0_service" => default_objects + %w{port},
                "gtp_mm_v1_service" => default_objects + %w{port},
                "compound_tcp_service" => default_objects + %w{svc_type port},
                "tcp_citrix_service" => default_objects + %w{citrix_application_name port},
                "rpc_service" => default_objects + %w{port},
                "other_service" => default_objects + %w{protocol exp},
                "icmpv6_service" => default_objects + %w{icmp_code icmp_type},
                "icmp_service" => default_objects + %w{icmp_code icmp_type},
              }

    service_objects = Hash.new
    service_objects_by_type = Hash.new

    doc.find("//services/service").each do |node|
      class_name = node.find_first("Class_Name").content

      unless get_obj.has_key?(class_name)
        miss_class[class_name] ||= 0
        miss_class[class_name] += 1
        next
      end
      # next unless class_name == "gtp_mm_v1_service"

      serv_obj = Hash.new
      puts "=== #{node.path} (#{class_name}) ===" if verbose
      get_obj[class_name].each do |obj|
        if obj == "__grp_member_fetch__"
          puts "  Num grp Members           - #{grp_member_fetch(node).length}" if verbose
          serv_obj[:grp_members] = grp_member_fetch(node)
        elsif obj =~ /^__\S+__$/
          puts "error: no method for: #{obj}" if verbose
          next
        else
          obj_ref = node.find_first(obj)
          obj_str = ""
          if obj_ref.class == LibXML::XML::Node
            obj_str = obj_ref.content
          end
          if obj == "type"
            obj_str = obj_str.downcase
          end
          serv_obj[obj.downcase.gsub(/\//, "_").to_sym] = obj_str
          puts "  #{obj.ljust(25)} - #{obj_str}" if verbose
        end
      end
      if service_objects.has_key?(serv_obj[:name])
        raise "#{serv_obj[:name]} is already defined! Inconsistent XML file??"
      else
        unless serv_obj.has_key?(:name)
          pp serv_obj
          raise "Missing key --> :name <-- of object above."
        end
        service_objects[serv_obj[:name]] = serv_obj
        service_objects_by_type[class_name] ||= Array.new
        service_objects_by_type[class_name] << service_objects[serv_obj[:name]]
      end
      puts if verbose
    end

    # Create link between objects.
    if service_objects_by_type.has_key?("service_group")
      service_objects_by_type["service_group"].each do |obj|
        tmp = Array.new
        obj[:grp_members].each do |member|
          tmp << service_objects[member]
        end
        service_objects[obj[:name]][:grp_members] = tmp
      end
    end

    # Create the Any service
    service_objects["Any"] = {:type => "any_type"}
    service_objects["any"] = service_objects["Any"]

    return service_objects
  end

  # ==> [ "member_obj1", "member_obj2", ... ]
  def self.grp_member_fetch(xml_node)
    unless xml_node.class == LibXML::XML::Node
      raise ArgumentError, "invalid xml node" 
    end
    members = Array.new
    xml_node.find("members/reference").each do |m|
      members << m.find_first("Name").content 
    end
    return members
  end
end
