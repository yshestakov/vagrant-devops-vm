#!/opt/vagrant/embedded/bin/ruby
#!/usr/bin/env ruby
require 'nokogiri'


QEMU_LIBVIRT_DIR='/etc/libvirt/qemu/'
PV_blacklist = ['15b3:1003', '15b3:1013', '15b3:1011']

module QemuHostdevLookup
    def get_mlnx_FVs()
        mlnx_devs = Hash.new
        IO.popen(['lspci', '-n']) { |lspci|
          body = lspci.read
          body.lines do |line|
            _addr,_class,_id = line.split(' ')
            if _id.start_with? '15b3:' then
              next if PV_blacklist.include? _id 
              mlnx_devs[_addr] = _id
            end
          end
        }
        mlnx_devs
    end

    def find_free_vf()
        mlnx_devs = get_mlnx_FVs()
        Dir.foreach(QEMU_LIBVIRT_DIR) do |item|
            next unless item.end_with? '.xml'
            # fn='/etc/libvirt/qemu/dev-r-vrt-079-006_yuriis.xml'
            fn = File.join(QEMU_LIBVIRT_DIR, item)
            vm_name = item[0..-5]
            doc = Nokogiri::XML(File.open(fn))
            doc.xpath('//hostdev/source/address').each do |dev|
                # puts dev
                bus = dev.attributes['bus'].value.to_i(16)
                slot = dev.attributes['slot'].value.to_i(16)
                func = dev.attributes['function'].value.to_i(16)
                addr = sprintf("%02x:%02x.%x", bus, slot, func)
                mlnx_devs[addr] = vm_name
            end
        end
        ret = []
        mlnx_devs.each { |addr, pciid|
            ret<<addr if pciid.start_with? '15b3:'
        }
        ret
    end

    # puts find_free_vf()
end
