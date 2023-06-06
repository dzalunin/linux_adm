# DNS-настройка и обслуживание. Настраиваем split-dns

Задача: 
* взять стенд https://github.com/erlong15/vagrant-bind 
* добавить еще один сервер client2
* завести в зоне dns.lab имена:
    - web1 - смотрит на клиент1
    - web2  смотрит на клиент2
* завести еще одну зону newdns.lab
* завести в ней запись
    - www - смотрит на обоих клиентов

* настроить split-dns
    - клиент1 - видит обе зоны, но в зоне dns.lab только web1
    - клиент2 видит только dns.lab

Решение:
- В Vagrant файле добавлен клиент 2:
```
config.vm.define "client2" do |client2|
    client2.vm.network "private_network", ip: "192.168.50.16", virtualbox__intnet: "dns"
    client2.vm.hostname = "client2"
end 
```
- В групповых переменных [all.yml](./ansible/group_vars/all.yml) заданы адреса DNS серверов, клиентов, необходимые ключи.

- Созданы Ansible роли:
  * [bind-client](./ansible/roles/bind-client) - настройка клиентов.
  * [bind-common](./ansible/roles/bind-common) - общая часть для конфигурирования DNS серверов
  * [bind-master](./ansible/roles/bind-master) - настройка master DNS
  * [bind-slave](./ansible/roles/bind-slave) - настройка slave DNS  

Результат работы split DNS в зонах dns.lab и newdns.lab:

* Клиент 1: 
```
[vagrant@client1 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.028 ms
64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.051 ms
^C
--- web1.dns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1007ms
rtt min/avg/max/mdev = 0.028/0.039/0.051/0.013 ms
[vagrant@client1 ~]$ ping web2.dns.lab
ping: web2.dns.lab: Name or service not known
[vagrant@client1 ~]$ ping www.newdns.lab
PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.031 ms
64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.051 ms
^C
--- www.newdns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 0.031/0.041/0.051/0.010 ms

```

* Клиент 2:
```
[vagrant@client2 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=1.09 ms
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=2 ttl=64 time=0.863 ms
^C
--- web1.dns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.863/0.976/1.090/0.117 ms
[vagrant@client2 ~]$ ping web2.dns.lab
PING web2.dns.lab (192.168.50.16) 56(84) bytes of data.
64 bytes from client2 (192.168.50.16): icmp_seq=1 ttl=64 time=0.034 ms
64 bytes from client2 (192.168.50.16): icmp_seq=2 ttl=64 time=0.061 ms
^C
--- web2.dns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.034/0.047/0.061/0.015 ms
[vagrant@client2 ~]$ ping www.newdns.lab
ping: www.newdns.lab: Name or service not known
```