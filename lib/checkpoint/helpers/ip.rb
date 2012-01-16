
module Checkpoint::Helpers::IP

  def valid_ipv4?(addr)
    if addr =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      return $~.captures.all? do |i|
        i.to_i <= 0xff
      end
    else
      return false
    end
  end

  def valid_ipv4_cidr?(addr)
    (addr,bit) = addr.split("/")

    return false if bit.is_a?(NilClass)
    return false unless bit.to_i.between?(0, 32)
    return valid_ipv4?(addr)
  end

  def valid_ipv4_ipnetmask?(addr)
    (addr,netmask) = addr.split("/")

    return false if netmask.is_a?(NilClass)
    return false unless valid_ipv4?(netmask)
    return valid_ipv4?(addr)
  end

end
