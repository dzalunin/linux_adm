#!/bin/bash

# Скрипт выводит:
# - Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
# - Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
# - Ошибки веб-сервера/приложения c момента последнего запуска;
# - Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.

#----------------------------------Константы------------------------------------------#

# Установка локали для форматирования дат.
LANG=en_EN

# В файле записан момент последнего обработанного события из лога.
LAST_START_FILE=".last_start"
LOCK_FILE="${0##*/}.lck"
START_FREQUENCY=3600
RECORDSET_SIZE=10

# Рабочие файлы
LOG_FILE="./access-4560-644067.log"
#LOG_FILE="./NASA_access_log_Aug95"
LOG_DATE_FORMAT="%d/%b/%Y:%H:%M:%S"


#-------------------------------Библиотека функций---------------------------------------#

function log_recordset {
    awk -v start="[$1" -v end="[$2" '$4 >= start && $4 < end { print $0}' $LOG_FILE
}

function calc_stats {
    sort | uniq -c | sort -nr | head -n $RECORDSET_SIZE
}

function generate_report {

    REPORT=$(
        printf "Access log analysis from %s to %s\n" $1 $2
        
        echo   "Top clients"
        printf "%8d - %s\n" `log_recordset $1 $2 | awk {'print $1'} | calc_stats`
        
        echo   "Top resources"
        printf "%8d - %s\n" `log_recordset $1 $2 | awk {'print $7'} | calc_stats`
        
        echo   "Top HTTP codes"
        printf "%8d - %s\n" `log_recordset $1 $2 | awk '$6 ~ /\"[A-Z]+$/ {print $6}' | calc_stats`

        echo   "Errors"
        log_recordset $1 $2 | sed 's| HTTP\/[0-9a-zA-Z]*\.[0-9]||g' | awk '$8 >= 400 {printf "%4s%s\n", " ",$0}'

        echo   "---------------------------------------------------------------------------------"
    )

    echo "$REPORT"
}


#----------------------------Раздел основной программы-----------------------------------#

# Если запустить скрипт с параметром debug - будет проанализирован весь лог
if [ $1 == 'debug' ];
then
    echo `awk '{ if (NR==1) print $4 }' $LOG_FILE | sed -e 's,\/, ,g' -e 's,:, ,' -e 's,\[,,' | xargs -0 -i date -d "{}" "+%s"` > $LAST_START_FILE
fi

# noclobber - запрет перезаписи содержимого файла при перенаправлении для тек. сессии. Это гарантирует, что вторая сессия его не перезапишет.
if ( set -o noclobber; echo "$$" > "$LOCK_FILE") 2> /dev/null;
then
    # Устанавливаем блокировку
    trap 'rm -f "$LOCK_FILE"; exit $?' INT TERM EXIT

    # Если с предыдущего запуска остался timestamp - используем его как отправную точку.
    # Иначе от текущей даты отнимаем час и за этот период собираем статистику. 
    now=`date +%s`
    if [ -f "$LAST_START_FILE" ]; then
        start_ts=`cat $LAST_START_FILE`
    else 
        start_ts=$(($now - $START_FREQUENCY))
    fi
    
    end_ts=$now
    # end_ts=$(($start_ts + $START_FREQUENCY))
    
    # Задаем пограничные значения периода
    start_date=`date -d "@$start_ts" +"$LOG_DATE_FORMAT"`
    end_date=`date -d "@$end_ts" +"$LOG_DATE_FORMAT"`

    # Генерируем отчет
    generate_report $start_date $end_date

    # Запоминаем конец периода
    if [ "$end_ts" -le "$now" ];
    then
        echo $end_ts > $LAST_START_FILE
    fi

    # Снимаем блокировку
    rm -f "$LOCK_FILE"
    trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $LOCK_FILE."
   echo "Held by $(cat $LOCK_FILE)"
fi
