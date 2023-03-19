# Docker

## Задача
1. Написать Dockerfile на базе apache/nginx который будет содержать две статичные web-страницы
на разных портах. Например, 8080 и 3000.
2. Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам
localhost:8080 и localhost:3000
3. Добавить 2 вольюма. Один для логов приложения, другой для web-страниц.

## Выполнение

Структура проекта:
* files/nginx.conf.tmplt - шаблон конфигурационного файла nginx
* init.sh - скрипт, ответвтвенный за размещение html  страниц и генерацию конфигурационных файлов nginx
* src/site*/index.html - страница сайта
* src/site*/site.ini - настройки публикации сайта, такие как порт или url
* docker-compose.yml - конфигурационный файл для запуска контейнера с помощью docker compose   


Запуск сборки docker образа:
```sh
root@8-C:~/linux_adm$ sudo docker build . -t hw
[+] Building 3.5s (8/8) FINISHED                                                                                                                                                                                       
 => [internal] load build definition from Dockerfile                                         0.2s
 => => transferring dockerfile: 145B                                                         0.0s
 => [internal] load .dockerignore                                                            0.3s
 => => transferring context: 2B                                                              0.0s
 => [internal] load metadata for docker.io/library/nginx:latest                              0.0s
 => [internal] load build context                                                            0.1s
 => => transferring context: 416B                                                            0.0s
 => CACHED [1/3] FROM docker.io/library/nginx:latest                                         0.0s
 => [2/3] ADD build /tmp/build                                                               0.7s
 => [3/3] RUN chmod +x /tmp/build/init.sh && /tmp/build/init.sh && rm -rf /tmp/build         1.4s
 => exporting to image                                                                       0.9s
 => => exporting layers                                                                      0.8s
 => => writing image sha256:42c98ab3cdb851c99f143cff4e35e7fb1c6bdce51ad6817aa04c856974bf9c2f 0.0s
 => => naming to docker.io/library/hw                              
```

Запуск контейнера с пробросом портов:
```sh
root@8-C:~/linux_adm$ docker run -d -p 8080:8080 -p 3000:3000 --rm --name nginx hw
4471d291638a0415e31efc3b0d5bd9c0947a50593d8e3841eb59cf0722bf82ab
```

Создание томов в директории /var/lib/docker/volumes
```sh
root@8-C:~/linux_adm$ docker volume create nginx_html
nginx_html
root@8-C:~/linux_adm$ docker volume create nginx_log
nginx_log
```

Добавление директив по сохранению логов в файлы в шаблон конфига files/nginx.conf.tmplt. После пересобираем образ.
```
access_log /var/log/nginx/%name%_access.log;
error_log /var/log/nginx/%name%_error.log;
``` 

Запуск контейнера с пробросом портов и томов:
```sh
root@8-C:~/linux_adm$ sudo docker run -d -p 8080:8080 -p 3000:3000 -v nginx_html:/usr/share/nginx/html -v nginx_log:/var/log/nginx --rm --name nginx hw
20a0eef2ea66cd2aaf917b28bc88a57dbf30a44caaeb3c5d1ed4ecee70ba6a42

root@8-C:~/linux_adm$ tree /var/lib/docker/volumes/
/var/lib/docker/volumes/
├── backingFsBlockDev
├── metadata.db
├── nginx_html
│   └── _data
│       ├── site1
│       │   └── index.html
│       └── site2
│           └── index.html
└── nginx_log
    └── _data
        ├── access.log -> /dev/stdout
        ├── error.log -> /dev/stderr
        ├── site1_access.log
        ├── site1_error.log
        ├── site2_access.log
        └── site2_error.log
```

Альтернативный запуск с монтированием томов и портов через docker compose
```sh
root@8-C:~/linux_adm$ sudo docker compose up -d
[+] Running 4/4
 ⠿ Network linux_adm_default      Created  0.3s
 ⠿ Volume "linux_adm_nginx_html"  Created  0.0s
 ⠿ Volume "linux_adm_nginx_log"   Created  0.0s
 ⠿ Container linux_adm-nginx-1    Started 

 root@8-C:~/linux_adm$ tree /var/lib/docker/volumes/
/var/lib/docker/volumes/
├── backingFsBlockDev
├── linux_adm_nginx_html
│   └── _data
│       ├── site1
│       │   └── index.html
│       └── site2
│           └── index.html
├── linux_adm_nginx_log
│   └── _data
│       ├── access.log -> /dev/stdout
│       ├── error.log -> /dev/stderr
│       ├── site1_access.log
│       ├── site1_error.log
│       ├── site2_access.log
│       └── site2_error.log
└── metadata.db

```

