#!/bin/bash

set -ex

HTTPD_ENV_DIR="/etc/sysconfig"
HTTPD_CONFIG_DIR="/etc/httpd/conf"
HTTPD_UNIT="/usr/lib/systemd/system/httpd.service"
REQUIREMENTS="httpd"

function install_requirements {
   yum install epel-release -y && yum install $REQUIREMENTS -y 
}

function add_httpd_config_template {
    if [ -e $HTTPD_UNIT.bak ]; then
        return
    fi

    template_unit=`dirname $HTTPD_UNIT`/httpd@.service

    cp $HTTPD_UNIT $HTTPD_UNIT.bak

    mv $HTTPD_UNIT $template_unit

    sed -i -e ' /EnvironmentFile/ s/$/-%i/g' $template_unit

    systemctl daemon-reload
}

function create_httpd_instance {

    instance_name=$1
    instance_port=$2
    instance_config=$instance_name.conf

    env_file=$HTTPD_ENV_DIR/httpd-$instance_name
    if [ -e $env_file ]; then
        return
    fi

    echo "OPTIONS=-f conf/$instance_config" > $env_file
    echo "Enviroment file $env_file was created."

    cat $HTTPD_CONFIG_DIR/httpd.conf | \
    sed \
    -e '/^ *#.*$/d' \
    -e '/^$/d' \
    -e "/ServerRoot/a PidFile \"/var/run/httpd-$instance_name.pid\"" \
    -e "s/Listen [0-9]*/Listen $instance_port/g" \
    > $HTTPD_CONFIG_DIR/$instance_config

    echo "Httpd config file $HTTPD_CONFIG_DIR/$instance_config was created."

    systemctl start httpd@$instance_name.service

    systemctl status httpd@$instance_name.service
}

function stop_httpd {

    base_instance_status=`systemctl is-active httpd.service`
    if [ $base_instance_status == active ]; then
        systemctl stop httpd.service
        systemctl disable httpd.service
    fi
}

install_requirements

setenforce 0

stop_httpd

add_httpd_config_template

create_httpd_instance first 8080

create_httpd_instance second 9090