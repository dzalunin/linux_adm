# Домашнее задание 4 (ZFS)


## Подготовка

* Загружаем скрипт, подключаемся, задаем права на исполнение, запускаем под root. 

```sh
dmitry@8-C:~/Documents/linux_adm$ vagrant upload scripts/homework.sh 
Uploading scripts/homework.sh to homework.sh
Upload has completed successfully!

  Source: scripts/homework.sh
  Destination: homework.sh
dmitry@8-C:~/Documents/linux_adm$ vagrant ssh
[vagrant@zfs ~]$ sudo -i
[root@zfs ~]# cp /home/vagrant/homework.sh ~
[root@zfs ~]# chmod 770 homework.sh 
[root@zfs ~]# ./homework.sh 
```

## Определение алгоритма с наилучшим сжатием

* Turn on kernel module zfs
```sh
[root@ ~]# modprobe zfs
```

* Show all block devices

```sh
[root@ ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  514M  0 disk 
sdc      8:32   0  514M  0 disk 
sdd      8:48   0  514M  0 disk 
sde      8:64   0  514M  0 disk 
sdf      8:80   0  514M  0 disk 
sdg      8:96   0  514M  0 disk 
sdh      8:112  0  514M  0 disk 
sdi      8:128  0  514M  0 disk 
```

* Create pools with different compression algoritns (lzjb, lz4, gzip-9, zle) 

```sh
[root@ ~]# zpool create pl_1 mirror /dev/sd{b..c} && zfs set compression=lzjb pl_1
[root@ ~]# zpool create pl_2 mirror /dev/sd{d..e} && zfs set compression=lz4 pl_2
[root@ ~]# zpool create pl_3 mirror /dev/sd{f..g} && zfs set compression=gzip-9 pl_3
[root@ ~]# zpool create pl_4 mirror /dev/sd{h..i} && zfs set compression=zle pl_4
[root@ ~]# zpool list
NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pl_1   480M   140K   480M        -         -     0%     0%  1.00x    ONLINE  -
pl_2   480M   118K   480M        -         -     0%     0%  1.00x    ONLINE  -
pl_3   480M   129K   480M        -         -     0%     0%  1.00x    ONLINE  -
pl_4   480M   129K   480M        -         -     0%     0%  1.00x    ONLINE  -
[root@ ~]# zfs get all | grep compression
pl_1  compression           lzjb                   local
pl_2  compression           lz4                    local
pl_3  compression           gzip-9                 local
pl_4  compression           zle                    local
```

* Download test file and copy it on each pool

```sh
[root@ ~]# wget -P ~ 'https://gutenberg.org/cache/epub/2600/pg2600.converter.log'
--2023-02-05 21:27:38--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40903378 (39M) [text/plain]
Saving to: '/root/pg2600.converter.log'

100%[==================================================================================================================================================================================>] 40,903,378  3.89MB/s   in 18s    

2023-02-05 21:27:56 (2.17 MB/s) - '/root/pg2600.converter.log' saved [40903378/40903378]

[root@ ~]# for i in {1..4}; do cp ~/pg2600.converter.log /pl_$i; done 
```

* Check file size on each pool

```sh
[root@ ~]# ls -l /pl_*
/pl_1:
total 22043
-rw-r--r--. 1 root root 40903378 Feb  5 21:27 pg2600.converter.log

/pl_2:
total 17983
-rw-r--r--. 1 root root 40903378 Feb  5 21:27 pg2600.converter.log

/pl_3:
total 8746
-rw-r--r--. 1 root root 40903378 Feb  5 21:28 pg2600.converter.log

/pl_4:
total 27924
-rw-r--r--. 1 root root 40903378 Feb  5 21:28 pg2600.converter.log
```

* Find algoritm with max compression

```sh
min_pool=$(du /pl* | sort -t, -k1 | head -1 | awk {'print $2'})
zfs get compression /pl_2
NAME  PROPERTY     VALUE     SOURCE
pl_2  compression  lz4       local
```

## Определить настройки пула

* Download and extract foreign pool arch

```sh
[root@ ~]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
--2023-02-05 21:28:05--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
Resolving drive.google.com (drive.google.com)... 173.194.221.194
Connecting to drive.google.com (drive.google.com)|173.194.221.194|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download [following]
--2023-02-05 21:28:05--  https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
Reusing existing connection to drive.google.com:443.
HTTP request sent, awaiting response... 303 See Other
Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/ua59e15jh0b27cctjkqn9cne68cona1s/1675632450000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download&uuid=22b91c23-5059-4c06-9b49-4a4c9f7e1a91 [following]
Warning: wildcards not supported in HTTP.
--2023-02-05 21:28:15--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/ua59e15jh0b27cctjkqn9cne68cona1s/1675632450000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download&uuid=22b91c23-5059-4c06-9b49-4a4c9f7e1a91
Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 142.251.36.65
Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|142.251.36.65|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/x-gzip]
Saving to: 'archive.tar.gz'

100%[==================================================================================================================================================================================>] 7,275,140   8.07MB/s   in 0.9s   

2023-02-05 21:28:17 (8.07 MB/s) - 'archive.tar.gz' saved [7275140/7275140]

[root@ ~]# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```

* Check pool can be imported

```sh
[root@ ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
Import pool otus
[root@ ~]# zpool import -d zpoolexport/ otus pl_otus
[root@ ~]# zpool status pl_otus
  pool: pl_otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	pl_otus                      ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```

* Check pool settungs

```sh
[root@ ~]# zfs get all pl_otus | grep 'checksum\|readonly\|recordsize\|compression\|available'
pl_otus  available             350M                   -
pl_otus  recordsize            128K                   local
pl_otus  checksum              sha256                 local
pl_otus  compression           zle                    local
pl_otus  readonly              off                    default
```


## Работа со снапшотами

* Download snapshot file. Snapshot was creatad by command 'zfs send otus/storage@task2 > otus_task2.file'

```sh
[root@ ~]# wget -O otus_task2.file --no-check-certificate 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'
--2023-02-05 21:28:23--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Resolving drive.google.com (drive.google.com)... 173.194.221.194
Connecting to drive.google.com (drive.google.com)|173.194.221.194|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download [following]
--2023-02-05 21:28:23--  https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Reusing existing connection to drive.google.com:443.
HTTP request sent, awaiting response... 303 See Other
Location: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/eltdutdlr65kjkn065n7ug3l4u0uadck/1675632450000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download&uuid=519e14c2-b7aa-4a57-87ab-e25225155ec6 [following]
Warning: wildcards not supported in HTTP.
--2023-02-05 21:28:24--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/eltdutdlr65kjkn065n7ug3l4u0uadck/1675632450000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download&uuid=519e14c2-b7aa-4a57-87ab-e25225155ec6
Resolving doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 142.251.36.65
Connecting to doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|142.251.36.65|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: 'otus_task2.file'

100%[==================================================================================================================================================================================>] 5,432,736   7.59MB/s   in 0.7s   

2023-02-05 21:28:25 (7.59 MB/s) - 'otus_task2.file' saved [5432736/5432736]
```

* Restore snapshot file

```sh
[root@ ~]# zfs receive pl_otus/storage@task2 < otus_task2.file
```

* Find secret message

```sh
[root@ ~]# secret=$(find /pl_otus/storage/ -name 'secret_message' 2> /dev/null)
[root@ ~]# echo $secret
/pl_otus/storage/task1/file_mess/secret_message
```
* Read message

```sh
[root@ ~]# cat $secret
https://github.com/sindresorhus/awesome
```
