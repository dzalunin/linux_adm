#!/bin/bash

# Гарантируем, что скрипт завершит работу, как только он встретит
# - любой ненулевой код завершения,
# - использование неопределенных переменных,
# - неправильные команды, переданные по каналу
# set -o errexit
# set -o nounset
# set -o pipefail

format_string="%-9s %-4s %-5s %-4s %-30s\n"

function readsocket {
    for soc in `readlink $1/fd/* | awk -F: '/socket/ {print $NF}' | sed -e 's/\[//g' -e 's/\]//g' | sort | uniq`; do 
        grep -R "$soc" $1/net/ | awk '{print $8}'
    done  
}

printf "$format_string" COMMAND PID USER FD NAME
for ps_dir in `find /proc/ -type d -regex '\/proc\/[0-9]*'`; do
    if [ ! -d $ps_dir ]; then
        continue
    fi
    echo "------------------------------- $ps_dir --------------------------------------"

    pid=`echo $ps_dir | awk -F/ {'print $NF'}`
    command=`awk -F'[: ]' {'print $1'} $ps_dir/comm | cut -c1-9`
    uid=`awk '/Uid/ {print $2}' $ps_dir/status`

    user=`id -nu $uid`

    # Выводим рабочий каталог
    printf "$format_string" $command $pid $user 'cwd' `readlink $ps_dir/cwd` 

    # Выводим root каталог
    printf "$format_string" $command $pid $user 'rtd' `readlink $ps_dir/root` 

    # Выводим файлы, отображаемые в память
    # Это механизм, который позволяет отображать файлы на участок памяти.
    # Таким образом, при чтении данных из неё, производится считывание соответствующих байт из файла.
    # С записью аналогично. 
    for name in `readlink $ps_dir/map_files/* | uniq`; do 
        printf "$format_string" $command $pid $user 'mem' $name 
    done  


    # Выводим занятые файлы
    for name in `readlink $ps_dir/fd/* | awk -F: '!/socket/ {print $NF}' | sort | uniq`; do 
        printf "$format_string" $command $pid $user '' $name 
    done  

    # Выводим данные по соккетам
    for name in `readsocket $ps_dir | sort | uniq | grep '\/'`; do
        printf "$format_string" $command $pid $user '' $name 
    done  
done