class Checkpoint::NetworkObject::Handler
  class NoSuchObject < StandardError
  end

  include Enumerable

  attr_reader :objects
  attr_accessor :class_name

  def initialize(obj_hash, verbose=false)
    @objects = Hash.new
    obj_hash.each_pair do |name, ref|
      begin
        puts "Loading object: #{name}..." if verbose
        @objects[name] = Checkpoint::NetworkObject.create(ref)
      rescue => e
        puts "-- Rescue load failed for object: #{name} --"
        p ref
        puts
        raise e
      end
    end
  end
  
  def [](name)
    unless @objects.has_key?(name)
      # Dirty hack to fix objects that dont exist in networks.xml
      if @objects.has_key?(name.downcase)
        name = name.downcase
      else
        raise(NoSuchObject.new(%{name: "#{name}"}))
      end
    end
    return @objects[name]
  end

  def object_exist?(name)
    if @objects.has_key?(name)
      return true
    else
      return false
    end
  end

  def print_objects(opts={})
    opts[:name_regexp] = /.*/ if opts[:name_regexp].nil?
    opts[:class_name_regexp] = /.*/ if opts[:class_name_regexp].nil?

    @objects.keys.grep(opts[:name_regexp]).each do |obj|
      object = @objects[obj]
      if opts[:class_name_regexp].match(object.class.to_s)
        puts object.to_string
        puts
      end
    end
  end

  def each
    objects.each_pair do |name, object|
      yield object
    end
  end

  def self.load(file)
    unless File.exist?(file.to_s)
      raise "No such file: \"#{file}\""
    end
    if file =~ /\.mar\s*$/ 
      return self.load_marshal(file)
    elsif file =~ /\.xml\s*$/ 
      return self.load_xml(file)
    else
      raise ArgumentError, "Expected a filename ending with .mar or .xml"
    end
  end

  def self.load_xml(file)
    objects = Checkpoint::Parse::NetworkObjectsXml.file(file)
    return self.new(objects)
  end

  def self.load_marshal(file)
    Marshal.load(File.read(file))
  end

end
