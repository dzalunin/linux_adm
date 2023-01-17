
#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm --create -l 5 -n 5 /dev/md1 /dev/sd{b,c,d,e,f}

yes | mkfs.ext4 /dev/md1
mkdir -p /mnt/md1
mount  /dev/md1 /mnt/md1

mkdir -p /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

echo "/dev/md1    /mnt/md1   ext4    defaults    0    1" >> /etc/fstab