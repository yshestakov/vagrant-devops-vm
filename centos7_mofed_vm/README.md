# Installation of MOFED and latest Lustre on centos/7 Vagrant box

Need to note that installation of MLNX OFED requires presence of MLNX HCA,
so that I have find out the way how to add  VF (as pci device) 
passed-through into the VM at the start.

That is tricky a bit: I need to know which VF is not used, i.e. could
be added to the new VM. 

There are 2 ways. Simple one - hardcode bus,slot,function like below:

        config.vm.define vm_name do |domain|
          domain.vm.provider :libvirt do |libvirt|
              libvirt.pci :bus => '0x04', :slot => '0x04', :function => '0x1'
          end
          ...
        end


And a bit more advanced with help of `../qemu_hostdev_lookup.rb` helper script:

        require_relative '../qemu_hostdev_lookup.rb'
        include QemuHostdevLookup
        Vagrant.configure("2") do |config|
          ...
          config.vm.define vm_name do |domain|
            domain.vm.provider :libvirt do |libvirt|
                vfs = find_free_vf()
                unless(vfs.empty?) 
                  bus,slot,func = vfs[0].split(/[:.]/).map{|x| "0x#{x}"}
                  libvirt.pci :bus => bus, :slot => slot, :function => func
                end
            end
            ...
          end
        end

