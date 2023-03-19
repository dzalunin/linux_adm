#!/bin/bash

HTML_DIR='/usr/share/nginx/html'
CONFIG_DIR='/etc/nginx/conf.d'

rm -rf $CONFIG_DIR/* $HTML_DIR/*
for full_path in `find $CWD/src/site* -type d`; do
    name=`echo $full_path | awk -F/ {'print $NF'}`    
    port=`awk -F: '/port/ {print $2}' $full_path/site.ini`
    url=`awk -F: '/url/ {print $2}' $full_path/site.ini`

    mkdir $HTML_DIR/$name
    cp $full_path/*.html $HTML_DIR/$name
    cat $CWD/files/nginx.conf.tmplt | sed -e "s/%name%/$name/g" -e "s/%port%/$port/g" -e "s/%url%/$url/g" > $CONFIG_DIR/$name.conf
done
