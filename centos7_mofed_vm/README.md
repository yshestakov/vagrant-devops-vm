# Installation of MOFED and latest Lustre on centos/7 Vagrant box

Need to note that installation of MLNX OFED requires presence of MLNX HCA,
so that I have find out the way how to add  VF (as pci device) 
passed-through into the VM at the start.
That is tricky a bit: I need to know which VF is not used, i.e. could
be added to the new VM.