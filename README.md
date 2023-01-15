## Домашнее задание 1

# Работа с машиной, созданной по Vagrant файлу
* Запуск машины, подключение по ssh
```
dmitry@8-C:~/Documents/linux_adm$ vagrant up
Bringing machine 'raid-create' up with 'virtualbox' provider...
==> raid-create: Importing base box 'centos/stream8'...
....
    raid-create: Complete!

dmitry@8-C:~/Documents/linux_adm$ vagrant ssh
[vagrant@raid-create ~]$ 
```

# Вывод имеющихся блочных устройств

```sh
[vagrant@raid-create ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   10G  0 disk 
-sda1   8:1    0   10G  0 part /
sdb      8:16   0  250M  0 disk 
sdc      8:32   0  250M  0 disk 
sdd      8:48   0  250M  0 disk 
sde      8:64   0  250M  0 disk 
sdf      8:80   0  250M  0 disk 
sdg      8:96   0  100M  0 disk 


[[vagrant@raid-create ~]$ sudo fdisk -l /dev/sd*
Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xf07c3c50

Device     Boot Start      End  Sectors Size Id Type
/dev/sda1  *     2048 20971519 20969472  10G 83 Linux


Disk /dev/sda1: 10 GiB, 10736369664 bytes, 20969472 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 250 MiB, 262144000 bytes, 512000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 250 MiB, 262144000 bytes, 512000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 250 MiB, 262144000 bytes, 512000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 250 MiB, 262144000 bytes, 512000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdf: 250 MiB, 262144000 bytes, 512000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdg: 100 MiB, 104857600 bytes, 204800 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

# Сборка RAID 5 (один из дисков меньшего объема)

* Запуск создания нового raid md01
```sh
vagrant@raid-create ~]$ mdadm --create -l 5 -n 5 /dev/md1 /dev/sd{c,d,e,f,g}
mdadm: must be super-user to perform this action
[vagrant@raid-create ~]$ sudo mdadm --create -l 5 -n 5 /dev/md1 /dev/sd{c,d,e,f,g}
mdadm: largest drive (/dev/sdc) exceeds size (100352K) by more than 1%
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```

* Отслеживание статуса инициализации нового массива
```sh
[vagrant@raid-create ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md1 : active raid5 sdg[5] sdf[3] sde[2] sdd[1] sdc[0]
      401408 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>
```

* Просмотр информации по собранному массиву
```sh
[vagrant@raid-create ~]$ sudo mdadm --detail /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Jan 15 21:40:33 2023
        Raid Level : raid5
        Array Size : 401408 (392.00 MiB 411.04 MB)
     Used Dev Size : 100352 (98.00 MiB 102.76 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 21:40:39 2023
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raid-create:1  (local to host raid-create)
              UUID : 4389cffe:efefaaae:6260c070:1158d8bd
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       3       8       80        3      active sync   /dev/sdf
       5       8       96        4      active sync   /dev/sdg
```

* Создание файловой системы и монтирование

```sh
[vagrant@raid-create ~]$ sudo mkfs.ext4 /dev/md1 
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 401408 1k blocks and 100352 inodes
Filesystem UUID: 0b528b50-5ad9-43e8-b6ce-663b1748ead7
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729, 204801, 221185

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 
[vagrant@raid-create ~]$ sudo mount  /dev/md1 /mnt/
[vagrant@raid-create ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        467M     0  467M   0% /dev
tmpfs           485M     0  485M   0% /dev/shm
tmpfs           485M   13M  472M   3% /run
tmpfs           485M     0  485M   0% /sys/fs/cgroup
/dev/sda1        10G  3.5G  6.6G  35% /
tmpfs            97M     0   97M   0% /run/user/1000
/dev/md1        372M  2.2M  346M   1% /mnt
```
# Удаление / добавление диска из массива

* Пометка диска как failed
```sh
[[vagrant@raid-create ~]$ sudo mdadm --manage /dev/md1 --fail /dev/sdg
mdadm: set /dev/sdg faulty in /dev/md1

[vagrant@raid-create ~]$ sudo mdadm --detail /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Jan 15 21:40:33 2023
        Raid Level : raid5
        Array Size : 401408 (392.00 MiB 411.04 MB)
     Used Dev Size : 100352 (98.00 MiB 102.76 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 21:49:02 2023
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raid-create:1  (local to host raid-create)
              UUID : 4389cffe:efefaaae:6260c070:1158d8bd
            Events : 40

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       3       8       80        3      active sync   /dev/sdf
       -       0        0        4      removed

       5       8       96        -      faulty   /dev/sdg

```

* Извлечение диска (после выполнения диск можно физически извлечь)

```sh
[vagrant@raid-create ~]$ sudo mdadm --manage /dev/md1 --remove /dev/sdg
mdadm: hot removed /dev/sdg from /dev/md1
```

* Добавление диска в массив

```sh
[vagrant@raid-create ~]$ sudo mdadm --manage /dev/md1 --add /dev/sdb
mdadm: added /dev/sdb

[vagrant@raid-create ~]$ sudo mdadm --detail /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Jan 15 21:40:33 2023
        Raid Level : raid5
        Array Size : 401408 (392.00 MiB 411.04 MB)
     Used Dev Size : 100352 (98.00 MiB 102.76 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 21:51:42 2023
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raid-create:1  (local to host raid-create)
              UUID : 4389cffe:efefaaae:6260c070:1158d8bd
            Events : 102

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       3       8       80        3      active sync   /dev/sdf
       5       8       16        4      active sync   /dev/sdb
```

# Увеличение размера массива (поставили диск большего размера)

```sh
[vagrant@raid-create ~]$ sudo mdadm --grow --size=max /dev/md1
mdadm: component size of /dev/md1 has been set to 253952K

vagrant@raid-create ~]$ sudo mdadm --detail /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Jan 15 21:40:33 2023
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 21:56:26 2023
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raid-create:1  (local to host raid-create)
              UUID : 4389cffe:efefaaae:6260c070:1158d8bd
            Events : 114

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       3       8       80        3      active sync   /dev/sdf
       5       8       16        4      active sync   /dev/sdb

[vagrant@raid-create ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        467M     0  467M   0% /dev
tmpfs           485M     0  485M   0% /dev/shm
tmpfs           485M   13M  472M   3% /run
tmpfs           485M     0  485M   0% /sys/fs/cgroup
/dev/sda1        10G  3.5G  6.6G  35% /
tmpfs            97M     0   97M   0% /run/user/1000
/dev/md1        372M  2.2M  346M   1% /mnt

[vagrant@raid-create ~]$ sudo resize2fs /dev/md1 
resize2fs 1.45.6 (20-Mar-2020)
Filesystem at /dev/md1 is mounted on /mnt; on-line resizing required
old_desc_blocks = 4, new_desc_blocks = 8
The filesystem on /dev/md1 is now 1015808 (1k) blocks long.

[vagrant@raid-create ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        467M     0  467M   0% /dev
tmpfs           485M     0  485M   0% /dev/shm
tmpfs           485M   13M  472M   3% /run
tmpfs           485M     0  485M   0% /sys/fs/cgroup
/dev/sda1        10G  3.5G  6.6G  35% /
tmpfs            97M     0   97M   0% /run/user/1000
/dev/md1        953M  2.6M  903M   1% /mnt
```

# Остановка raid

```sh
[vagrant@raid-create ~]$ sudo umount /mnt/
[vagrant@raid-create ~]$ sudo mdadm -S /dev/md1 
mdadm: stopped /dev/md1
```

# Просмотр информации о raid по 1 из устройств

```sh
[vagrant@raid-create ~]$ sudo mdadm --examine /dev/sdc
/dev/sdc:
          Magic : a92b4efc
        Version : 1.2
    Feature Map : 0x0
     Array UUID : 4389cffe:efefaaae:6260c070:1158d8bd
           Name : raid-create:1  (local to host raid-create)
  Creation Time : Sun Jan 15 21:40:33 2023
     Raid Level : raid5
   Raid Devices : 5

 Avail Dev Size : 507904 sectors (248.00 MiB 260.05 MB)
     Array Size : 1015808 KiB (992.00 MiB 1040.19 MB)
    Data Offset : 4096 sectors
   Super Offset : 8 sectors
   Unused Space : before=4016 sectors, after=0 sectors
          State : clean
    Device UUID : 69c3e90e:2ef1db60:49eda84e:1bb7a6cc

    Update Time : Sun Jan 15 22:04:29 2023
  Bad Block Log : 512 entries available at offset 16 sectors
       Checksum : dc3e9329 - correct
         Events : 114

         Layout : left-symmetric
     Chunk Size : 512K

   Device Role : Active device 0
   Array State : AAAAA ('A' == active, '.' == missing, 'R' == replacing)
```

# Просмотр информации о raid

```sh
[vagrant@raid-create ~]$ sudo mdadm --examine --scan
ARRAY /dev/md/1  metadata=1.2 UUID=4389cffe:efefaaae:6260c070:1158d8bd name=raid-create:1
ARRAY /dev/md/1  metadata=1.2 UUID=4389cffe:efefaaae:6260c070:1158d8bd name=raid-create:1
```

# Автосборка raid

```sh
[vagrant@raid-create ~]$ sudo mdadm --assemble --scan
mdadm: /dev/md/1 has been started with 5 drives.
mdadm: Found some drive for an array that is already active: /dev/md/1
mdadm: giving up.
mdadm: Found some drive for an array that is already active: /dev/md/1
mdadm: giving up.
[vagrant@raid-create ~]$ sudo mdadm --detail /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Jan 15 21:40:33 2023
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 22:04:29 2023
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raid-create:1  (local to host raid-create)
              UUID : 4389cffe:efefaaae:6260c070:1158d8bd
            Events : 114

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       3       8       80        3      active sync   /dev/sdf
       5       8       16        4      active sync   /dev/sdb

```