# Инициализация системы. Systemd
## Написать сервис, который будет раз в 30 секунд мониторитþ лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig.

Скрипт: [hw.sh](./scripts/hw.sh)

Результат выполнения
```
[vagrant@sysd linux_adm]$ sudo ./hw.sh 
+ init_config
+ '[' -e /etc/sysconfig/watchlog ']'
++ dirname /etc/sysconfig/watchlog
+ config_dir=/etc/sysconfig
+ mkdir -p /etc/sysconfig
+ cat
+ echo 'Default config /etc/sysconfig/watchlog was initialazed.'
Default config /etc/sysconfig/watchlog was initialazed.
+ init_watchlog_script
+ '[' -e /opt/watchlog.sh ']'
+ cat
+ chmod +x /opt/watchlog.sh
+ echo 'Watchlog script /opt/watchlog.sh was created.'
Watchlog script /opt/watchlog.sh was created.
+ create_service
+ service_file=/etc/systemd/system/watchlog.service
+ '[' -e /etc/systemd/system/watchlog.service ']'
+ cat
+ echo 'Unit /etc/systemd/system/watchlog.service was created.'
Unit /etc/systemd/system/watchlog.service was created.
+ create_timer
+ timer=watchlog.timer
+ timer_file=/etc/systemd/system/watchlog.timer
+ '[' -e /etc/systemd/system/watchlog.timer ']'
+ service=watchlog.service
+ cat
+ systemctl daemon-reload
+ systemctl start watchlog.timer
+ echo 'Timer /etc/systemd/system/watchlog.timer was created.'
Timer /etc/systemd/system/watchlog.timer was created.
+ exit 0

[vagrant@sysd linux_adm]$ sudo systemctl status watchlog.timer
● watchlog.timer - Run watchlog script every 30 second
   Loaded: loaded (/etc/systemd/system/watchlog.timer; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-04-02 09:21:42 UTC; 30s ago

Apr 02 09:21:42 sysd systemd[1]: Started Run watchlog script every 30 second.
[vagrant@sysd linux_adm]$ sudo tail -f /var/log/messages
Apr  2 09:21:41 sysd systemd: Reloading.
Apr  2 09:21:42 sysd systemd: Started Run watchlog script every 30 second.
Apr  2 09:21:42 sysd systemd: Starting My watchlog service...
Apr  2 09:21:42 sysd watchlog.sh: Run at Sun Apr  2 09:21:42 UTC 2023: with WORD=ALERT, LOG=/var/log/watchlog.log
Apr  2 09:21:42 sysd root: Sun Apr  2 09:21:42 UTC 2023: I found word, Master!
Apr  2 09:21:42 sysd systemd: Started My watchlog service.
Apr  2 09:22:12 sysd systemd: Starting My watchlog service...
Apr  2 09:22:12 sysd watchlog.sh: Run at Sun Apr  2 09:22:12 UTC 2023: with WORD=ALERT, LOG=/var/log/watchlog.log
Apr  2 09:22:12 sysd root: Sun Apr  2 09:22:12 UTC 2023: I found word, Master!
Apr  2 09:22:12 sysd systemd: Started My watchlog service.
Apr  2 09:23:02 sysd systemd: Starting My watchlog service...
Apr  2 09:23:02 sysd watchlog.sh: Run at Sun Apr  2 09:23:02 UTC 2023: with WORD=ALERT, LOG=/var/log/watchlog.log
Apr  2 09:23:02 sysd root: Sun Apr  2 09:23:02 UTC 2023: I found word, Master!
Apr  2 09:23:02 sysd systemd: Started My watchlog service.
```

## Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно также называться.

Скрипт: [hw1.sh](./scripts/hw1.sh)

Результат выполнения:
```
[vagrant@sysd linux_adm]$ sudo ./hw1.sh 
+ SPAWN_FCGI_EXEC=/usr/bin/spawn-fcgi
+ SPAWN_FCGI_PROG=spawn-fcgi
+ SPAWN_FCGI_CONFIG=/etc/sysconfig/spawn-fcgi
+ SPAWN_FCGI_SOCKET=/var/run/php-fcgi.sock
+ SPAWN_FCGI_EXEC_OPTIONS='-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi'
+ REQUIREMENTS='spawn-fcgi php php-cli mod_fcgid httpd'
+ install_requirements
+ yum install epel-release -y
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.widexs.nl
 * epel: mirror.yandex.ru
 * extras: mirror.widexs.nl
 * updates: mirror.sitbv.nl
Package epel-release-7-14.noarch already installed and latest version
Nothing to do
+ yum install spawn-fcgi php php-cli mod_fcgid httpd -y
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.widexs.nl
 * epel: mirror.yandex.ru
 * extras: mirror.ams1.nl.leaseweb.net
 * updates: mirror.prolocation.net
Package spawn-fcgi-1.6.3-5.el7.x86_64 already installed and latest version
Package php-5.4.16-48.el7.x86_64 already installed and latest version
Package php-cli-5.4.16-48.el7.x86_64 already installed and latest version
Package mod_fcgid-2.3.9-6.el7.x86_64 already installed and latest version
Package httpd-2.4.6-98.el7.centos.6.x86_64 already installed and latest version
Nothing to do
+ prepare_spawn_fcgi_config
+ '[' -e /etc/sysconfig/spawn-fcgi.bak ']'
+ cp /etc/sysconfig/spawn-fcgi /etc/sysconfig/spawn-fcgi.bak
+ sed -i -e 's|^#SOCKET=.*|SOCKET=/var/run/php-fcgi.sock|g' -e 's|^#OPTIONS=.*|OPTIONS=-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi|g' /etc/sysconfig/spawn-fcgi
+ create_spawn_fcgi_unit
+ unit=/etc/systemd/system/spawn-fcgi.service
+ '[' -e /etc/systemd/system/spawn-fcgi.service ']'
+ cat
+ echo 'Unit /etc/systemd/system/spawn-fcgi.service was created.'
Unit /etc/systemd/system/spawn-fcgi.service was created.
+ start_spawn_fcgi
+ systemctl start spawn-fcgi
+ systemctl status spawn-fcgi
● spawn-fcgi.service - spawn-fcgi startup service
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-04-02 11:55:53 UTC; 14ms ago
 Main PID: 4788 (spawn-fcgi)
   CGroup: /system.slice/spawn-fcgi.service
           ‣ 4788 [spawn-fcgi]

Apr 02 11:55:53 sysd systemd[1]: Started spawn-fcgi startup service.
```

## Дополнить unit-файл apache httpd возможности запустить несколько инстансов сервера с разными конфигами.

Скрипт: [hw2.sh](./scripts/hw2.sh)

Результат выполнения:
```
[vagrant@sysd linux_adm]$ sudo ./hw2.sh 
+ HTTPD_ENV_DIR=/etc/sysconfig
+ HTTPD_CONFIG_DIR=/etc/httpd/conf
+ HTTPD_UNIT=/usr/lib/systemd/system/httpd.service
+ REQUIREMENTS=httpd
+ setenforce 0
+ stop_httpd
++ systemctl is-active httpd.service
+ base_instance_status=active
+ '[' active == active ']'
+ systemctl stop httpd.service
+ systemctl disable httpd.service
+ add_httpd_config_template
+ '[' -e /usr/lib/systemd/system/httpd.service.bak ']'
++ dirname /usr/lib/systemd/system/httpd.service
+ template_unit=/usr/lib/systemd/system/httpd@.service
+ cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd.service.bak
+ mv /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service
+ sed -i -e ' /EnvironmentFile/ s/$/-%i/g' /usr/lib/systemd/system/httpd@.service
+ systemctl daemon-reload
+ create_httpd_instance first 8080
+ instance_name=first
+ instance_port=8080
+ instance_config=first.conf
+ env_file=/etc/sysconfig/httpd-first
+ '[' -e /etc/sysconfig/httpd-first ']'
+ echo 'OPTIONS=-f conf/first.conf'
+ echo 'Enviroment file /etc/sysconfig/httpd-first was created.'
Enviroment file /etc/sysconfig/httpd-first was created.
+ cat /etc/httpd/conf/httpd.conf
+ sed -e '/^ *#.*$/d' -e '/^$/d' -e '/ServerRoot/a PidFile "/var/run/httpd-first.pid"' -e 's/Listen [0-9]*/Listen 8080/g'
+ echo 'Httpd config file /etc/httpd/conf/first.conf was created.'
Httpd config file /etc/httpd/conf/first.conf was created.
+ systemctl start httpd@first.service
+ systemctl status httpd@first.service
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2023-04-04 20:38:34 UTC; 6ms ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 3547 (httpd)
   Status: "Processing requests..."
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─3547 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3548 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3549 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3550 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3551 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─3552 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─3553 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Apr 04 20:38:34 sysd systemd[1]: Starting The Apache HTTP Server...
Apr 04 20:38:34 sysd httpd[3547]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName...his message
Apr 04 20:38:34 sysd systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
+ create_httpd_instance second 9090
+ instance_name=second
+ instance_port=9090
+ instance_config=second.conf
+ env_file=/etc/sysconfig/httpd-second
+ '[' -e /etc/sysconfig/httpd-second ']'
+ echo 'OPTIONS=-f conf/second.conf'
+ echo 'Enviroment file /etc/sysconfig/httpd-second was created.'
Enviroment file /etc/sysconfig/httpd-second was created.
+ cat /etc/httpd/conf/httpd.conf
+ sed -e '/^ *#.*$/d' -e '/^$/d' -e '/ServerRoot/a PidFile "/var/run/httpd-second.pid"' -e 's/Listen [0-9]*/Listen 9090/g'
+ echo 'Httpd config file /etc/httpd/conf/second.conf was created.'
Httpd config file /etc/httpd/conf/second.conf was created.
+ systemctl start httpd@second.service
+ systemctl status httpd@second.service
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2023-04-04 20:38:34 UTC; 7ms ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 3563 (httpd)
   Status: "Processing requests..."
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─3563 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3564 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3565 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3566 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3567 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─3568 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─3569 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Apr 04 20:38:34 sysd systemd[1]: Starting The Apache HTTP Server...
Apr 04 20:38:34 sysd httpd[3563]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName...his message
Apr 04 20:38:34 sysd systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
[vagrant@sysd linux_adm]$ 
```