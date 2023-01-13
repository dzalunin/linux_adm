## Домашнее задание 1

# Работа с машиной, созданной по Vagrant файлу
* Запуск машины
```
vagrant up
```
* Подключение по ssh от имени пользователя vagrant
```
vagrant ssh kernel-update
``` 

# Обновление ядра

* Подключение репозитория ELRepo for RHEL-8.
``` sh
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

```

* Показать текущую версию ядра.
 ``` sh
 [vagrant@kernel-update ~]$ uname -r
  4.18.0-277.el8.x86_64
```

* Загрузка последнего стабильного ядра
``` sh
[vagrant@kernel-update ~]$ sudo yum --enablerepo elrepo-kernel install kernel-ml -y
Last metadata expiration check: 0:01:45 ago on Wed Jan 11 19:19:37 2023.
Dependencies resolved.
================================================================================
 Package              Arch      Version                  Repository        Size
================================================================================
Installing:
 kernel-ml            x86_64    6.1.4-1.el8.elrepo       elrepo-kernel     98 k
Installing dependencies:
 kernel-ml-core       x86_64    6.1.4-1.el8.elrepo       elrepo-kernel     34 M
 kernel-ml-modules    x86_64    6.1.4-1.el8.elrepo       elrepo-kernel     30 M

Transaction Summary
================================================================================
Install  3 Packages

Total download size: 64 M
Installed size: 100 M
Downloading Packages:
(1/3): kernel-ml-6.1.4-1.el8.elrepo.x86_64.rpm   72 kB/s |  98 kB     00:01    
(2/3): kernel-ml-modules-6.1.4-1.el8.elrepo.x86 592 kB/s |  30 MB     00:51    
(3/3): kernel-ml-core-6.1.4-1.el8.elrepo.x86_64 644 kB/s |  34 MB     00:54    
--------------------------------------------------------------------------------
Total                                           1.2 MB/s |  64 MB     00:55     
warning: /var/cache/dnf/elrepo-kernel-e80375c2d5802dd1/packages/kernel-ml-6.1.4-1.el8.elrepo.x86_64.rpm: Header V4 DSA/SHA256 Signature, key ID baadae52: NOKEY
ELRepo.org Community Enterprise Linux Kernel Re 1.6 MB/s | 1.7 kB     00:00    
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : kernel-ml-core-6.1.4-1.el8.elrepo.x86_64               1/3 
  Running scriptlet: kernel-ml-core-6.1.4-1.el8.elrepo.x86_64               1/3 
  Installing       : kernel-ml-modules-6.1.4-1.el8.elrepo.x86_64            2/3 
  Running scriptlet: kernel-ml-modules-6.1.4-1.el8.elrepo.x86_64            2/3 
  Installing       : kernel-ml-6.1.4-1.el8.elrepo.x86_64                    3/3 
  Running scriptlet: kernel-ml-core-6.1.4-1.el8.elrepo.x86_64               3/3 
  Running scriptlet: kernel-ml-6.1.4-1.el8.elrepo.x86_64                    3/3 
  Verifying        : kernel-ml-6.1.4-1.el8.elrepo.x86_64                    1/3 
  Verifying        : kernel-ml-core-6.1.4-1.el8.elrepo.x86_64               2/3 
  Verifying        : kernel-ml-modules-6.1.4-1.el8.elrepo.x86_64            3/3 

Installed:
  kernel-ml-6.1.4-1.el8.elrepo.x86_64                                           
  kernel-ml-core-6.1.4-1.el8.elrepo.x86_64                                      
  kernel-ml-modules-6.1.4-1.el8.elrepo.x86_64                                   

Complete!
```

* Убедимся, что ядро загрузилось
``` sh
[vagrant@kernel-update ~]$ ls /boot
System.map-4.18.0-277.el8.x86_64      initramfs-4.18.0-277.el8.x86_64.img
System.map-6.1.4-1.el8.elrepo.x86_64  initramfs-6.1.4-1.el8.elrepo.x86_64.img
config-4.18.0-277.el8.x86_64          loader
config-6.1.4-1.el8.elrepo.x86_64      vmlinuz-4.18.0-277.el8.x86_64
efi                                   vmlinuz-6.1.4-1.el8.elrepo.x86_64
grub2
```

* Инициализация конфига загрузчика
``` sh
[vagrant@kernel-update ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done
```

* Установка ядра по умолчанию
``` sh
[vagrant@kernel-update ~]$ sudo grub2-set-default 0
```

* Перезагрузка машины
``` sh
[vagrant@kernel-update ~]$ sudo reboot
```

* Убедимся, что обновление применилось.
 ``` sh
[vagrant@kernel-update ~]$ uname -r
6.1.4-1.el8.elrepo.x86_64
```

# Создание образа системы

* Билд образа
```
dmitry@8-C:~/Documents/linux_adm/packer$ packer build centos.json
entos-8: output will be in this color.

==> centos-8: Retrieving Guest additions
==> centos-8: Trying /usr/share/virtualbox/VBoxGuestAdditions.iso
==> centos-8: Trying /usr/share/virtualbox/VBoxGuestAdditions.iso
==> centos-8: /usr/share/virtualbox/VBoxGuestAdditions.iso => /usr/share/virtualbox/VBoxGuestAdditions.iso
==> centos-8: Retrieving ISO
==> centos-8: Trying http://mirror.linux-ia64.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20221222-boot.iso
==> centos-8: Trying http://mirror.linux-ia64.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20221222-boot.iso?checksum=sha256%3A70030af1dff1aed857e9a53311b452d330fa82902b3567f6640f119f9fa29e70
==> centos-8: http://mirror.linux-ia64.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20221222-boot.iso?checksum=sha256%3A70030af1dff1aed857e9a53311b452d330fa82902b3567f6640f119f9fa29e70 => /home/dmitry/.cache/packer/63c773361a1bd851414732ba88cf00779c1fb249.iso
==> centos-8: Starting HTTP server on port 8673
==> centos-8: Creating virtual machine...
==> centos-8: Creating hard drive builds/packer-centos-vm.vdi with size 10240 MiB...
==> centos-8: Mounting ISOs...
    centos-8: Mounting boot ISO...
==> centos-8: Creating forwarded port mapping for communicator (SSH, WinRM, etc) (host port 3251)
==> centos-8: Executing custom VBoxManage commands...
    centos-8: Executing: modifyvm packer-centos-vm --memory 1024
    centos-8: Executing: modifyvm packer-centos-vm --cpus 2
    centos-8: Executing: modifyvm packer-centos-vm --nat-localhostreachable1 on
==> centos-8: Starting the virtual machine...
==> centos-8: Waiting 10s for boot...
==> centos-8: Typing the boot command...
==> centos-8: Using SSH communicator to connect: 127.0.0.1
==> centos-8: Waiting for SSH to become available...
==> centos-8: Connected to SSH!
==> centos-8: Uploading VirtualBox version info (7.0.4)
==> centos-8: Uploading VirtualBox guest additions ISO...
==> centos-8: Pausing 20s before the next provisioner...
==> centos-8: Provisioning with shell script: scripts/kernel-update.sh
    centos-8: CentOS Stream 8 - AppStream                     7.2 MB/s |  27 MB     00:03
    centos-8: CentOS Stream 8 - BaseOS                        8.9 MB/s |  26 MB     00:02
    centos-8: CentOS Stream 8 - Extras                        133 kB/s |  18 kB     00:00
    centos-8: CentOS Stream 8 - Extras common packages         27 kB/s | 5.2 kB     00:00
    centos-8: elrepo-release-8.el8.elrepo.noarch.rpm          8.4 kB/s |  13 kB     00:01
    centos-8: Dependencies resolved.
    centos-8: ================================================================================
    centos-8:  Package             Arch        Version                Repository         Size
    centos-8: ================================================================================
    centos-8: Installing:
    centos-8:  elrepo-release      noarch      8.3-1.el8.elrepo       @commandline       13 k
    centos-8:
    centos-8: Transaction Summary
    centos-8: ================================================================================
    centos-8: Install  1 Package
    centos-8:
    centos-8: Total size: 13 k
    centos-8: Installed size: 5.0 k
    centos-8: Downloading Packages:
    centos-8: Running transaction check
    centos-8: Transaction check succeeded.
    centos-8: Running transaction test
    centos-8: Transaction test succeeded.
    centos-8: Running transaction
    centos-8:   Preparing        :                                                        1/1
    centos-8:   Installing       : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1
    centos-8:   Verifying        : elrepo-release-8.3-1.el8.elrepo.noarch                 1/1
    centos-8:
    centos-8: Installed:
    centos-8:   elrepo-release-8.3-1.el8.elrepo.noarch
    centos-8:
    centos-8: Complete!
    centos-8: ELRepo.org Community Enterprise Linux Repositor 329 kB/s | 242 kB     00:00
    centos-8: ELRepo.org Community Enterprise Linux Kernel Re 1.6 MB/s | 2.1 MB     00:01
    centos-8: Dependencies resolved.
    centos-8: ================================================================================
    centos-8:  Package              Arch      Version                  Repository        Size
    centos-8: ================================================================================
    centos-8: Installing:
    centos-8:  kernel-ml            x86_64    6.1.5-1.el8.elrepo       elrepo-kernel     98 k
    centos-8: Installing dependencies:
    centos-8:  kernel-ml-core       x86_64    6.1.5-1.el8.elrepo       elrepo-kernel     34 M
    centos-8:  kernel-ml-modules    x86_64    6.1.5-1.el8.elrepo       elrepo-kernel     30 M
    centos-8:
    centos-8: Transaction Summary
    centos-8: ================================================================================
    centos-8: Install  3 Packages
    centos-8:
    centos-8: Total download size: 64 M
    centos-8: Installed size: 100 M
    centos-8: Downloading Packages:
    centos-8: (1/3): kernel-ml-6.1.5-1.el8.elrepo.x86_64.rpm  470 kB/s |  98 kB     00:00
    centos-8: (2/3): kernel-ml-modules-6.1.5-1.el8.elrepo.x86 2.5 MB/s |  30 MB     00:11
    centos-8: (3/3): kernel-ml-core-6.1.5-1.el8.elrepo.x86_64 2.8 MB/s |  34 MB     00:12
    centos-8: --------------------------------------------------------------------------------
    centos-8: Total                                           5.2 MB/s |  64 MB     00:12
    centos-8: ELRepo.org Community Enterprise Linux Kernel Re 1.6 MB/s | 1.7 kB     00:00
    centos-8: Importing GPG key 0xBAADAE52:
    centos-8:  Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
    centos-8:  Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
    centos-8:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
    centos-8: Key imported successfully
    centos-8: Running transaction check
    centos-8: Transaction check succeeded.
    centos-8: Running transaction test
    centos-8: Transaction test succeeded.
    centos-8: Running transaction
    centos-8:   Preparing        :                                                        1/1
    centos-8:   Installing       : kernel-ml-core-6.1.5-1.el8.elrepo.x86_64               1/3
    centos-8:   Running scriptlet: kernel-ml-core-6.1.5-1.el8.elrepo.x86_64               1/3
    centos-8:   Installing       : kernel-ml-modules-6.1.5-1.el8.elrepo.x86_64            2/3
    centos-8:   Running scriptlet: kernel-ml-modules-6.1.5-1.el8.elrepo.x86_64            2/3
    centos-8:   Installing       : kernel-ml-6.1.5-1.el8.elrepo.x86_64                    3/3
    centos-8:   Running scriptlet: kernel-ml-core-6.1.5-1.el8.elrepo.x86_64               3/3
    centos-8:   Running scriptlet: kernel-ml-6.1.5-1.el8.elrepo.x86_64                    3/3
    centos-8:   Verifying        : kernel-ml-6.1.5-1.el8.elrepo.x86_64                    1/3
    centos-8:   Verifying        : kernel-ml-core-6.1.5-1.el8.elrepo.x86_64               2/3
    centos-8:   Verifying        : kernel-ml-modules-6.1.5-1.el8.elrepo.x86_64            3/3
    centos-8:
    centos-8: Installed:
    centos-8:   kernel-ml-6.1.5-1.el8.elrepo.x86_64
    centos-8:   kernel-ml-core-6.1.5-1.el8.elrepo.x86_64
    centos-8:   kernel-ml-modules-6.1.5-1.el8.elrepo.x86_64
    centos-8:
    centos-8: Complete!
    centos-8: Generating grub configuration file ...
    centos-8: done
    centos-8: Grub update done.
==> centos-8: Provisioning with shell script: scripts/clean.sh
    centos-8: Last metadata expiration check: 0:01:30 ago on Fri 13 Jan 2023 02:56:58 PM EST.
    centos-8: Dependencies resolved.
    centos-8: Nothing to do.
    centos-8: Complete!
    centos-8: 39 files removed
==> centos-8: Gracefully halting virtual machine...
==> centos-8: Preparing to export machine...
    centos-8: Deleting forwarded port mapping for the communicator (SSH, WinRM, etc) (host port 3251)
==> centos-8: Exporting virtual machine...
    centos-8: Executing: export packer-centos-vm --output builds/packer-centos-vm.ovf --manifest --vsys 0 --description CentOS Stream 8 with kernel 6.x --version 8
==> centos-8: Cleaning up floppy disk...
==> centos-8: Deregistering and deleting VM...
==> centos-8: Running post-processor: vagrant
==> centos-8 (vagrant): Creating a dummy Vagrant box to ensure the host system can create one correctly
==> centos-8 (vagrant): Creating Vagrant box for 'virtualbox' provider
    centos-8 (vagrant): Copying from artifact: builds/packer-centos-vm-disk001.vmdk
    centos-8 (vagrant): Copying from artifact: builds/packer-centos-vm.mf
    centos-8 (vagrant): Copying from artifact: builds/packer-centos-vm.ovf
    centos-8 (vagrant): Renaming the OVF to box.ovf...
    centos-8 (vagrant): Compressing: Vagrantfile
    centos-8 (vagrant): Compressing: box.ovf
    centos-8 (vagrant): Compressing: metadata.json
    centos-8 (vagrant): Compressing: packer-centos-vm-disk001.vmdk
    centos-8 (vagrant): Compressing: packer-centos-vm.mf
Build 'centos-8' finished after 14 minutes 51 seconds.

==> Wait completed after 14 minutes 52 seconds

==> Builds finished. The artifacts of successful builds are:
--> centos-8: 'virtualbox' provider box: centos-8-kernel-6-x86_64-Minimal.box
``` 

# Импорт образа в Vagrant
``` sh
dmitry@8-C:~/Documents/linux_adm/packer$ vagrant box add centos8-kernel6 centos-8-kernel-6-x86_64-Minimal.box 
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'centos8-kernel6' (v0) for provider: 
    box: Unpacking necessary files from: file:///home/dmitry/Documents/linux_adm/packer/centos-8-kernel-6-x86_64-Minimal.box
==> box: Successfully added box 'centos8-kernel6' (v0) for 'virtualbox'!
```

# Просмотр списка локальных образов
``` sh
dmitry@8-C:~/Documents/linux_adm/packer$ vagrant box list
centos/7        (virtualbox, 2004.01)
centos/stream8  (virtualbox, 20210210.0)
centos8-kernel6 (virtualbox, 0)
```

# Инициализация нового Vagrant файла
``` sh
dmitry@8-C:~/Documents/linux_adm$ vagrant init centos8-kernel6
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
```

# Запуск и проверка версии ядра
```sh
dmitry@8-C:~/Documents/linux_adm$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'centos8-kernel6'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: linux_adm_default_1673641438521_32295
==> default: Clearing any previously set network interfaces...
....

dmitry@8-C:~/Documents/linux_adm$ vagrant ssh
Last login: Fri Jan 13 15:30:02 2023 from 10.0.2.2
[vagrant@otus-c8 ~]$ sudo uname -r
6.1.5-1.el8.elrepo.x86_64
```
# Публикация образа в облаке Vagrant
```sh
dmitry@8-C:~/Documents/linux_adm/packer$ vagrant cloud auth login --token 123
The token was successfully saved.
You are already logged in.

dmitry@8-C:~/Documents/linux_adm/packer$ vagrant cloud publish --release dzalunin/centos8-kernel6 1.0 virtualbox centos-8-kernel-6-x86_64-Minimal.box
You are about to publish a box on Vagrant Cloud with the following options:
dzalunin/centos8-kernel6:   (v1.0) for provider 'virtualbox'
Automatic Release:     true
Do you wish to continue? [y/N]y
Saving box information...
Uploading provider with file /home/dmitry/Documents/linux_adm/packer/centos-8-kernel-6-x86_64-Minimal.box
Releasing box...
Complete! Published dzalunin/centos8-kernel6
Box:              dzalunin/centos8-kernel6
Description:      
Private:          yes
Created:          2023-01-13T20:58:27.554Z
Updated:          2023-01-13T20:58:27.554Z
Current Version:  N/A
Versions:         1.0
Downloads:        0
```

# Особенности

* Конфиг packer (centos.json)
Для корректной работы на virtualbox 7.0 в настройках машины нужно задать настройки сетевого адаптора (--nat-localhostreachableN)
```
    "vboxmanage":
    [
      ["modifyvm", "{{.Name}}", "--memory", "1024"],
      ["modifyvm", "{{.Name}}", "--cpus", "2"],
      ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]
    ]
```

* Для корректного применения kickstart конфига (http/ks.cfg) требуется поставить пакет @core
```
%packages
@core
%end
```

* Для выполнения provision скриптов пришлось в конфиге kickstart (http/ks.cfg) разрешить пользователю vagrant выполнять sudo без пароля
```
%post
echo "vagrant" | passwd --stdin vagrant
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
%end
```