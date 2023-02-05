#!/bin/bash

#************************** lib ******************************************************

USR="[$USER@$hostname ~]#"

function del_pools {
  for p in `zpool list -Ho name`
  do
    echo "$USR zpool destroy -f $p"
    zpool destroy -f "$p"
  done

  echo "zpool destroy -f pl_otus"
  zpool destroy -f pl_otus
}

function create_pools {
  echo "$USR zpool create pl_1 mirror /dev/sd{b..c} && zfs set compression=lzjb pl_1"
  zpool create pl_1 mirror /dev/sd{b..c} && zfs set compression=lzjb pl_1

  echo "$USR zpool create pl_2 mirror /dev/sd{d..e} && zfs set compression=lz4 pl_2"
  zpool create pl_2 mirror /dev/sd{d..e} && zfs set compression=lz4 pl_2

  echo "$USR zpool create pl_3 mirror /dev/sd{f..g} && zfs set compression=gzip-9 pl_3"
  zpool create pl_3 mirror /dev/sd{f..g} && zfs set compression=gzip-9 pl_3

  echo "$USR zpool create pl_4 mirror /dev/sd{h..i} && zfs set compression=zle pl_4"
  zpool create pl_4 mirror /dev/sd{h..i} && zfs set compression=zle pl_4
}

function clean_all {
  cd ~

  del_pools

  echo "$USR rm -f ~/*.log zpoolexport archive.tar.gz /pl_otus"
  rm -rf ~/*.log zpoolexport archive.tar.gz /pl_otus
}

#************************ Find algoritm with max compression *****************************************

echo "Turn on kernel module zfs"
echo "$USR modprobe zfs"
modprobe zfs

echo "Init"
clean_all

echo "Show all block devices"
echo "$USR lsblk"
lsblk

echo "Create pools with different compression algoritns (lzjb, lz4, gzip-9, zle) "
create_pools

echo "$USR zpool list"
zpool list

echo "$USR zfs get all | grep compression"
zfs get all | grep compression

echo "Download test file and copy it on each pool"

echo "$USR wget -P ~ 'https://gutenberg.org/cache/epub/2600/pg2600.converter.log'"
wget -P ~ 'https://gutenberg.org/cache/epub/2600/pg2600.converter.log'

echo "$USR for i in {1..4}; do cp ~/pg2600.converter.log /pl_\$i; done "
for i in {1..4}; do cp ~/pg2600.converter.log /pl_$i; done

echo "Check file size on each pool"
echo "$USR ls -l /pl_*"
ls -l /pl_*


echo "Find algoritm with max compression"
echo "min_pool=\$(du /pl* | sort -t, -k1 | head -1 | awk {'print \$2'})"
min_pool=$(du /pl* | sort -t, -k1 | head -1 | awk {'print $2'})

echo "zfs get compression $min_pool"
zfs get compression $min_pool

#************************ Check pool settings *****************************************
echo
echo "Download and extract foreign pool arch"

echo "$USR wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'"
wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'

echo "$USR tar -xzvf archive.tar.gz"
tar -xzvf archive.tar.gz

echo "Check pool can be imported"
echo "$USR zpool import -d zpoolexport/"
zpool import -d zpoolexport/

echo "Import pool otus"
echo "$USR zpool import -d zpoolexport/ otus pl_otus"
zpool import -d zpoolexport/ otus pl_otus

echo "$USR zpool status pl_otus"
zpool status pl_otus

echo "Check pool settungs"
echo "$USR zfs get all pl_otus | grep 'checksum\|readonly\|recordsize\|compression\|available'"
zfs get all pl_otus | grep 'checksum\|readonly\|recordsize\|compression\|available'


#************************ Snapshots *****************************************
echo
echo "Download snapshot file. Snapshot was creatad by command 'zfs send otus/storage@task2 > otus_task2.file'"
echo "$USR wget -O otus_task2.file --no-check-certificate 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'"
wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"

echo "Restore snapshot file"
echo "$USR zfs receive pl_otus/storage@task2 < otus_task2.file"
zfs receive pl_otus/storage@task2 < otus_task2.file

echo "Find secret message"
echo "$USR secret=\$(find /pl_otus/storage/ -name 'secret_message' 2> /dev/null)"
secret=$(find /pl_otus/storage/ -name 'secret_message' 2> /dev/null)

echo "$USR echo \$secret"
echo $secret

echo "Read message"
echo "$USR cat \$secret"
cat $secret