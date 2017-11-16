# Vagrant + LibVirt based provisioning of VMs

Get VM running by using Vagrant + LibVirt,
provision it with intration to NIS domain,
install "verification tools" with MLXRPC service.
In result the MV is read to be used as part of "storage verification" framework.

The project is based on "centos/7" Vagrant box.
Also, it depends on LibVirt 3.7 from CentOS CBS (Community Build System)
 and QEMU-KVM  `qemu-system-x86-2.0.0` package from EPEL, which has `nvme` device emulation.


## Prerequisites
* [Vagrant](https://www.vagrantup.com/)
* [Vagrant libvirt plugin](https://github.com/vagrant-libvirt/vagrant-libvirt)
* [CentOS CVS](http://cbs.centos.org/koji/)

### CentOS CBS repositories

Create `/etc/yum.repos.d/centos73-virt.repo` file:

    [kvm]
    name=centos7 kvm-common - $basearch
    baseurl=http://mirror.centos.org/centos-7/7/virt/$basearch/kvm-common/
    enabled=0
    gpgcheck=0

    [libvirt]
    name=centos7 libvirt - $basearch
    baseurl=http://mirror.centos.org/centos-7/7/virt/$basearch/libvirt-latest/
    enabled=1
    gpgcheck=0

    [ovirt-4.1]
    name=centos7 libvirt - $basearch
    baseurl=http://mirror.centos.org/centos-7/7/virt/$basearch/ovirt-4.1/
    enabled=1
    gpgcheck=0


## Installation

Install Vagrant libvirt plugin
```
sudo vagrant plugin install vagrant-libvirt
export VAGRANT_DEFAULT_PROVIDER=libvirt
```

Preload `centos/7` Vagrant box to reduce time of first `vagrant up` command

```
sudo vagrant box add centos/7
```

Clone the git repo into `vagrant-devops-vm` directory and provision VM with given name:

```
git@github.com:yshestakov/vagrant-devops-vm.git vagrant-devops-vm
cd vagrant-devops-vm/centos_mofed_vm
sudo VM_NAME=dev-r-vrt-099-001 vagrant up
```

