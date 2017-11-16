#!/bin/sh
# Author: yuriis
if [ -z "$MLNX_OFED_URL" ] ; then
  MLNX_OFED_URL=http://www.mellanox.com/downloads/ofed/MLNX_EN-4.2-1.0.1.0/mlnx-en-4.2-1.0.1.0-rhel7.4-x86_64.tgz
  MLNX_OFED_TGZ=${MLNX_OFED_URL##*/}
fi
set -e
########################
# EPEL
########################
echo "Install EPEL repo"
yum -q install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  || true

########################
# Wget, Git, Vim, Screen
########################
echo "Install wget, Git, ViM, screen, pcituils, fio, psmisc, lsof"
yum -q -y install wget git make gcc g++ glibc-devel vim-enhanced screen pciutils \
    fio psmic lsof createrepo rpm-build nvme-cli gtk2 atk \
    kernel-devel-`uname -r`

########################
# Postinstall
########################
echo "*** Move 'vagrant' user home to /var/lib/vagrant"
mv /home/vagrant /var/lib
sed -i 's#:/home/vagrant:#:/var/lib/vagrant:#' /etc/passwd


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
cd /tmp
wget -q ${MLNX_OFED_URL}
tar zxf ${MLNX_OFED_TGZ}
cd ${MLNX_OFED_TGZ%.tgz}
./install --with-nvmf 


echo "*** Done"
