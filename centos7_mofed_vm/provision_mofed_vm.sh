#!/bin/sh
# Author: yuriis
if [ -z "$MLNX_OFED_URL" ] ; then
  # MLNX_EN_URL=http://www.mellanox.com/downloads/ofed/MLNX_EN-4.2-1.0.1.0/mlnx-en-4.2-1.0.1.0-rhel7.4-x86_64.tgz
  MLNX_OFED_URL=http://content.mellanox.com/ofed/MLNX_OFED-4.2-1.0.0.0/MLNX_OFED_LINUX-4.2-1.0.0.0-rhel7.4-x86_64.tgz
  MLNX_OFED_TGZ=${MLNX_OFED_URL##*/}
fi
set -e
########################
# Move 'vagrant' user home
########################
if [ -d /home/vagrant ] ; then
  echo "*** Move 'vagrant' user home to /var/lib/vagrant"
  mv /home/vagrant /var/lib
  sed -i 's#:/home/vagrant:#:/var/lib/vagrant:#' /etc/passwd
fi

########################
# Disable IPv6 first of all for the time of installation
########################
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
if ip r l |grep -q 'default.*dev eth1' ; then
  ip r del default dev eth0 || true
fi

########################
# Wget, Git, Vim, Screen
########################
echo "Install base tools: wget, Git, ViM, screen"
yum -q -y install wget git vim-enhanced screen 

########################
# EPEL
########################
echo "Install EPEL repo"
yum -q install -y \
       https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  || true
#cd /vagrant
#if [ ! -e epel-release-latest-7.noarch.rpm ] ; then
#  wget -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#fi
#yum -q install /vagrant/epel-release-latest-7.noarch.rpm || true

########################
# Install more utils :)
########################
echo "Install kernel-devel, pcituils, fio, psmisc, lsof, ..."
yum -q -y install gcc g++ glibc-devel pciutils \
    fio psmic lsof createrepo rpm-build nvme-cli gtk2 atk \
    gcc-gfortran tcsh \
    kernel-devel-`uname -r`



########################
# attach to the NIS domain
# in the lab if needed#
test -x ../postinstall_itlab.sh && ../postinstall_itlab.sh


########################
# Do we need to update kernel and packages in general before installing OFED?
#----------------------
# Install "latest" OFED 4.2
# build=latest-4.2 /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install \
#   --with-nvmf  --add-kernel-support
echo "** Install MLNX_OFED"
cd /tmp
wget -q ${MLNX_OFED_URL}
tar zxf ${MLNX_OFED_TGZ}
cd ${MLNX_OFED_TGZ%.tgz}

# MLNX_EN:
# yes| ./install --with-nvmf
#   enable NICs - load modules
# /etc/init.d/mlnx-en.d start

# MLNX_OFED:
yes | ./mlnxofedinstall --dpdk --guest --with-nvmf --without-fw-update
#   load kernel modules
/etc/init.d/openibd start

# need to configure ipaddress(s)
# $ ibdev2netdev
# mlx5_0 port 1 ==> ib0 (Up)
mgmt_ip=$( ip a l eth1 |awk '$1 == "inet" {print $2}' )

ibdev2netdev |while read p _0 n _1 i _2 ; do 
  ifcfg=/etc/sysconfig/network-scripts/ifcfg-$i
  ip="1$n.${mgmt_ip#10.}"
  mask=$( ipcalc -m $ip )
  ntw=$( ipcalc -n $ip )
  brc=$( ipcalc -b $ip )
  ipa=
  cat <<EOF > $ifcfg
DEVICE=$i
BOOTPROTO=static
IPADDR=${ip%/[0-9]*}
$brc
$mask
$ntw
ONBOOT=yes
NM_CONTROLLED=no
EOF
  ifup $i
done
echo "*** Done"
