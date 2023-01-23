# Домашнее задание 3

## Уменþшитþ том под / до 8G
* Посмотреть имеющиеся блочные устройства
```sh
[root@lvm ~]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
```

* Создать новый физический том под /
```sh
[root@lvm ~]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[root@lvm ~]# pvs
  PV         VG         Fmt  Attr PSize   PFree 
  /dev/sda3  VolGroup00 lvm2 a--  <38.97g     0 
  /dev/sdb              lvm2 ---   10.00g 10.00g
```

* Создать новую группу томов vg_root
```sh
[root@lvm ~]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
[root@lvm ~]# vgs
  VG         #PV #LV #SN Attr   VSize   VFree  
  VolGroup00   1   2   0 wz--n- <38.97g      0 
  vg_root      1   0   0 wz--n- <10.00g <10.00g
```

* Создать логический том 
```sh
[root@lvm ~]# lvcreate -n main -l 100%FREE vg_root 
  Logical volume "main" created.
[root@lvm ~]# lvdisplay /dev/vg_root/main
  --- Logical volume ---
  LV Path                /dev/vg_root/main
  LV Name                main
  VG Name                vg_root
  LV UUID                DucuqE-PrLW-QM8Q-jCSF-7QDc-iSpK-KTb9nR
  LV Write Access        read/write
  LV Creation host, time lvm, 2023-01-22 19:02:10 +0000
  LV Status              available
  # open                 0
  LV Size                <10.00 GiB
  Current LE             2559
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
  ```

* Создание файловой системы xfs на логическом томе lv_root и монтирование в /mnt

```sh
[root@lvm ~]# mkfs.xfs /dev/vg_root/main
meta-data=/dev/vg_root/main      isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm ~]# mount /dev/vg_root/main /mnt/
[root@lvm ~]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  845M   37G   3% /
devtmpfs                         487M     0  487M   0% /dev
tmpfs                            496M     0  496M   0% /dev/shm
tmpfs                            496M  6.7M  490M   2% /run
tmpfs                            496M     0  496M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                            100M     0  100M   0% /run/user/1000
/dev/mapper/vg_root-main          10G   33M   10G   1% /mnt
```

* Создание дампа корневого раздела xfsdump, восстановление его в /mnt (xfsrestore). 
```sh
[root@lvm ~]# xfsdump -J - /dev/mapper/VolGroup00-LogVol00 | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
xfsrestore: using file dump (drive_simple) strategy
xfsdump: version 3.1.7 (dump format 3.0)
xfsrestore: version 3.1.7 (dump format 3.0)
xfsdump: level 0 dump of lvm:/
xfsdump: dump date: Sun Jan 22 19:18:48 2023
xfsdump: session id: 7edea8f7-2495-4dae-9ba9-dd88245eba2e
xfsdump: session label: ""
xfsrestore: searching media for dump
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 846814720 bytes
xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsrestore: examining media file 0
xfsrestore: dump description: 
xfsrestore: hostname: lvm
xfsrestore: mount point: /
xfsrestore: volume: /dev/mapper/VolGroup00-LogVol00
xfsrestore: session time: Sun Jan 22 19:18:48 2023
xfsrestore: level: 0
xfsrestore: session label: ""
xfsrestore: media label: ""
xfsrestore: file system id: b60e9498-0baa-4d9f-90aa-069048217fee
xfsrestore: session id: 7edea8f7-2495-4dae-9ba9-dd88245eba2e
xfsrestore: media id: 426e1012-3a02-403b-a369-a73869ed5b31
xfsrestore: searching media for directory dump
xfsrestore: reading directories
xfsdump: dumping non-directory files
xfsrestore: 2723 directories and 23704 entries processed
xfsrestore: directory post-processing
xfsrestore: restoring non-directory files
xfsdump: ending media file
xfsdump: media file size 823775632 bytes
xfsdump: dump size (non-dir files) : 810549040 bytes
xfsdump: dump complete: 30 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 30 seconds elapsed
xfsrestore: Restore Status: SUCCESS
[root@lvm ~]# ls -l /mnt
total 12
lrwxrwxrwx.  1 root root    7 Jan 22 19:18 bin -> usr/bin
drwxr-xr-x.  2 root root    6 May 12  2018 boot
drwxr-xr-x.  2 root root    6 May 12  2018 dev
drwxr-xr-x. 79 root root 8192 Jan 22 17:47 etc
drwxr-xr-x.  3 root root   21 May 12  2018 home
lrwxrwxrwx.  1 root root    7 Jan 22 19:18 lib -> usr/lib
lrwxrwxrwx.  1 root root    9 Jan 22 19:18 lib64 -> usr/lib64
drwxr-xr-x.  2 root root    6 Apr 11  2018 media
drwxr-xr-x.  5 root root   41 Jan 22 13:29 mnt
drwxr-xr-x.  2 root root    6 Apr 11  2018 opt
drwxr-xr-x.  2 root root    6 May 12  2018 proc
dr-xr-x---.  3 root root  170 Jan 19 19:58 root
drwxr-xr-x.  2 root root    6 May 12  2018 run
lrwxrwxrwx.  1 root root    8 Jan 22 19:18 sbin -> usr/sbin
drwxr-xr-x.  2 root root    6 Apr 11  2018 srv
drwxr-xr-x.  2 root root    6 May 12  2018 sys
drwxrwxrwt.  8 root root  193 Jan 22 19:04 tmp
drwxr-xr-x. 13 root root  155 May 12  2018 usr
drwxr-xr-x. 18 root root  254 Jan 19 19:27 var
```

* Переключаем разделы /proc/ /sys/ /dev/ /run/ /boot/ на соответствующие каталоги в /mnt.
```sh
[root@lvm ~]# mount --bind /proc/ /mnt/proc/
[root@lvm ~]# mount --bind /sys/ /mnt/sys/
[root@lvm ~]# mount --bind /dev/ /mnt/dev/
[root@lvm ~]# mount --bind /run/ /mnt/run/
[root@lvm ~]# mount --bind /boot/ /mnt/boot/
```

* Подменяем корень на /mnt

```sh
[root@lvm ~]# chroot /mnt/
```


* Генерация конфига загрузчика

```sh
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.conf
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
```

* Генерация initramfs
```sh
[root@lvm /]# cd boot
[root@lvm /]# ls -l
total 25980
-rw-r--r--. 1 root root   147823 May  9  2018 config-3.10.0-862.2.3.el7.x86_64
drwxr-xr-x. 3 root root       17 May 12  2018 efi
drwxr-xr-x. 2 root root       27 May 12  2018 grub
drwx------. 5 root root      114 Jan 22 19:51 grub2
-rw-------. 1 root root 16506787 May 12  2018 initramfs-3.10.0-862.2.3.el7.x86_64.img
-rw-r--r--. 1 root root   304926 May  9  2018 symvers-3.10.0-862.2.3.el7.x86_64.gz
-rw-------. 1 root root  3409102 May  9  2018 System.map-3.10.0-862.2.3.el7.x86_64
-rwxr-xr-x. 1 root root  6225056 May  9  2018 vmlinuz-3.10.0-862.2.3.el7.x86_64
[root@lvm boot]# dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
*** Including module: bash ***
*** Including module: nss-softokn ***
*** Including module: i18n ***
*** Including module: drm ***
*** Including module: plymouth ***
*** Including module: dm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 60-persistent-storage-dm.rules
Skipping udev rule: 55-dm.rules
*** Including module: kernel-modules ***
Omitting driver floppy
*** Including module: lvm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 56-lvm.rules
Skipping udev rule: 60-persistent-storage-lvm.rules
*** Including module: qemu ***
*** Including module: resume ***
*** Including module: rootfs-block ***
*** Including module: terminfo ***
*** Including module: udev-rules ***
Skipping udev rule: 40-redhat-cpu-hotplug.rules
Skipping udev rule: 91-permissions.rules
*** Including module: biosdevname ***
*** Including module: systemd ***
*** Including module: usrmount ***
*** Including module: base ***
*** Including module: fs-lib ***
*** Including module: shutdown ***
*** Including modules done ***
*** Installing kernel module dependencies and firmware ***
*** Installing kernel module dependencies and firmware done ***
*** Resolving executable dependencies ***
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** No early-microcode cpio image needed ***
*** Store current command line parameters ***
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```

* Изменение конфига загрузчика
```sh
[root@lvm boot]# vi /boot/grub2/grub.cfg
rd.lvm.lv=vg_root/main
```
* Перезагрузка

* Проверка, что / изменен
```sh
[root@lvm boot]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
└─vg_root-main          253:2    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
```

* Удаление старого логического тома / 
```sh
[root@lvm ~]# lvremove -vf /dev/VolGroup00/LogVol00 
    Removing VolGroup00-LogVol00 (253:2)
    Archiving volume group "VolGroup00" metadata (seqno 3).
    Releasing logical volume "LogVol00"
    Creating volume group backup "/etc/lvm/backup/VolGroup00" (seqno 4).
  Logical volume "LogVol00" successfully removed
[root@lvm ~]# lvs
  LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LogVol01 VolGroup00 -wi-ao----   1.50g                                                    
  main     vg_root    -wi-ao---- <10.00g    
```

* Подготовка нового логического тома под /
```sh
[root@lvm ~]# lvcreate -n LogVol00 -L 8G VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
[root@lvm ~]# lvs
  LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LogVol00 VolGroup00 -wi-a-----   8.00g                                                    
  LogVol01 VolGroup00 -wi-ao----   1.50g                                                    
  main     vg_root    -wi-ao---- <10.00g
[root@lvm ~]# mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm ~]# mount /dev/VolGroup00/LogVol00 /mnt
                                                     
```

* Перенос / обратно

```sh
[root@lvm ~]# xfsdump -J - /dev/vg_root/main | xfsrestore -J - /mnt
[root@lvm ~]# mount --bind /proc/ /mnt/proc/
[root@lvm ~]# mount --bind /sys/ /mnt/sys/
[root@lvm ~]# mount --bind /dev/ /mnt/dev/
[root@lvm ~]# mount --bind /run/ /mnt/run/
[root@lvm ~]# mount --bind /boot/ /mnt/boot/
[root@lvm ~]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@lvm /]# cd boot
[root@lvm boot]# dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
```

## Выделить том под /var - сделать в mirror

* Создание физических томов под var

```sh
[root@lvm boot]# pvcreate /dev/sd{d,e}
  Physical volume "/dev/sdd" successfully created.
  Physical volume "/dev/sde" successfully created.
```

* Создание общей группы томов 
```sh
[root@lvm boot]# vgcreate vg_var /dev/sdd /dev/sde
  Volume group "vg_var" successfully created
[root@lvm boot]# vgdisplay vg_var 
  --- Volume group ---
  VG Name               vg_var
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               1.99 GiB
  PE Size               4.00 MiB
  Total PE              510
  Alloc PE / Size       0 / 0   
  Free  PE / Size       510 / 1.99 GiB
  VG UUID               NUzqH8-vOYz-vVzI-dVdc-bIel-89Hf-rVwAOj
```

* Создание логического тома  
```sh
[root@lvm boot]# lvcreate -n lv_mirror -L1016M -m1 vg_var
  No input from event server.
  Logical volume "lv_mirror" created.
[root@lvm boot]# vgdisplay vg_var 
  --- Volume group ---
  VG Name               vg_var
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               1.99 GiB
  PE Size               4.00 MiB
  Total PE              510
  Alloc PE / Size       510 / 1.99 GiB
  Free  PE / Size       0 / 0   
  VG UUID               NUzqH8-vOYz-vVzI-dVdc-bIel-89Hf-rVwAOj
  [root@lvm boot]# lvdisplay /dev/vg_var/lv_mirror 
  --- Logical volume ---
  LV Path                /dev/vg_var/lv_mirror
  LV Name                lv_mirror
  VG Name                vg_var
  LV UUID                yaYjb3-xz33-ep4s-fNnc-Jio4-Ma6F-WpfLlS
  LV Write Access        read/write
  LV Creation host, time lvm, 2023-01-23 20:22:58 +0000
  LV Status              available
  # open                 0
  LV Size                1016.00 MiB
  Current LE             254
  Mirrored volumes       2
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:7
```

* Форматирование и перенос var

```sh
[root@lvm boot]# mkfs.xfs /dev/vg_var/lv_mirror
meta-data=/dev/vg_var/lv_mirror  isize=512    agcount=4, agsize=65024 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=260096, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=855, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm mnt]# mount /dev/vg_var/lv_mirror /mnt
[root@lvm mnt]# rsync -avHPSAX /var/ /mnt/
```

* Монтирование нового var
```sh
[root@lvm mnt]# umount /mnt
[root@lvm mnt]# mount /dev/vg
vga_arbiter  vg_root/     vg_var/      
[root@lvm mnt]# mount /dev/vg
vga_arbiter  vg_root/     vg_var/      
[root@lvm mnt]# mount /dev/vg_var/lv_mirror /var
[root@lvm mnt]# vi /etc/fstab
  UUID=0072e859-8674-4bfd-b1bc-ab70fc7187b0 /var           xfs    defaults         0 0 

reboot

[root@lvm ~]# lsblk
NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                           8:0    0   40G  0 disk 
├─sda1                        8:1    0    1M  0 part 
├─sda2                        8:2    0    1G  0 part /boot
└─sda3                        8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00     253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01     253:1    0  1.5G  0 lvm  [SWAP]
sdb                           8:16   0   10G  0 disk 
└─vg_root-main              253:7    0   10G  0 lvm  
sdc                           8:32   0    2G  0 disk 
sdd                           8:48   0    1G  0 disk 
├─vg_var-lv_mirror_rmeta_0  253:2    0    4M  0 lvm  
│ └─vg_var-lv_mirror        253:6    0 1016M  0 lvm  /var
└─vg_var-lv_mirror_rimage_0 253:3    0 1016M  0 lvm  
  └─vg_var-lv_mirror        253:6    0 1016M  0 lvm  /var
sde                           8:64   0    1G  0 disk 
├─vg_var-lv_mirror_rmeta_1  253:4    0    4M  0 lvm  
│ └─vg_var-lv_mirror        253:6    0 1016M  0 lvm  /var
└─vg_var-lv_mirror_rimage_1 253:5    0 1016M  0 lvm  
  └─vg_var-lv_mirror        253:6    0 1016M  0 lvm  /var
```


* Удаление лишнего
```sh
[root@lvm ~]# vgremove vg_root -f
  Logical volume "main" successfully removed
  Volume group "vg_root" successfully removed
[root@lvm ~]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
[root@lvm ~]# rm -rf /tmp/oldvar
 
```