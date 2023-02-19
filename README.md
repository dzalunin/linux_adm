# Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.

* Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
* Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
* Ошибки веб-сервера/приложения c момента последнего запуска;
* Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
* Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.
* В письме должен быть прописан обрабатываемый временной диапазон.

# Запуск скрипта в режиме отладки ./task.sh debug

Конфигурирование в коде скрипта:
- LOG_FILE задает: путь к логу 
- LOG_DATE_FORMAT: формат дат, используемая в логе
- START_FREQUENCY: планируемя частота запуска
- LANG: локаль

Результат:
```sh
Access log analysis from 14/Aug/2019:04:12:10 to 19/Feb/2023:19:54:46
Top clients
      45 - 93.158.167.130
      39 - 109.236.252.130
      37 - 212.57.117.19
      33 - 188.43.241.106
      31 - 87.250.233.68
      24 - 62.75.198.172
      22 - 148.251.223.21
      20 - 185.6.8.9
      17 - 217.118.66.161
      16 - 95.165.18.146
Top resources
     157 - /
     120 - /wp-login.php
      57 - /xmlrpc.php
      26 - /robots.txt
      12 - /favicon.ico
      11 - 400
       9 - /wp-includes/js/wp-embed.min.js?ver=5.0.4
       7 - /wp-admin/admin-post.php?page=301bulkoptions
       7 - /1
       6 - /wp-content/uploads/2016/10/robo5.jpg
Top HTTP codes
     499 - "GET
     156 - "POST
       3 - "HEAD
       1 - "PROPFIND
Errors
    93.158.167.130 - - [14/Aug/2019:05:02:20 +0300] "GET /" 404 169 "-" "Mozilla/5.0 (compatible; YandexMetrika/2.0; +http://yandex.com/bots yabs01)"rt=0.000 uct="-" uht="-" urt="-"
    87.250.233.68 - - [14/Aug/2019:05:04:20 +0300] "GET /" 404 169 "-" "Mozilla/5.0 (compatible; YandexMetrika/2.0; +http://yandex.com/bots yabs01)"rt=0.000 uct="-" uht="-" urt="-"
    107.179.102.58 - - [14/Aug/2019:05:22:10 +0300] "GET /wp-content/plugins/uploadify/readme.txt" 404 200 "http://dbadmins.ru/wp-content/plugins/uploadify/readme.txt" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36"rt=0.000 uct="-" uht="-" urt="-"
``
