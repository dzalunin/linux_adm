#!/bin/bash

set -ex

SPAWN_FCGI_EXEC="/usr/bin/spawn-fcgi"
SPAWN_FCGI_PROG="spawn-fcgi"
SPAWN_FCGI_CONFIG="/etc/sysconfig/spawn-fcgi"
SPAWN_FCGI_SOCKET=/var/run/php-fcgi.sock
SPAWN_FCGI_EXEC_OPTIONS="-u apache -g apache -s \$SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

REQUIREMENTS="spawn-fcgi php php-cli mod_fcgid httpd"


function install_requirements {
   yum install epel-release -y && yum install $REQUIREMENTS -y 
}

function prepare_spawn_fcgi_config {
    if [ -e $SPAWN_FCGI_CONFIG.bak ]; then
        return
    fi
    cp $SPAWN_FCGI_CONFIG $SPAWN_FCGI_CONFIG.bak

    sed -i \
    -e "s|^#SOCKET=.*|SOCKET=$SPAWN_FCGI_SOCKET|g" \
    -e "s|^#OPTIONS=.*|OPTIONS=$SPAWN_FCGI_EXEC_OPTIONS|g" \
    $SPAWN_FCGI_CONFIG
}

function create_spawn_fcgi_unit  {

    unit=/etc/systemd/system/${SPAWN_FCGI_PROG//'"'/}.service
    if [ -e $unit ]; then
        return
    fi

    cat << EOF > $unit
[Unit]
Description=$SPAWN_FCGI_PROG startup service
After=network.target

[Service]
Type=simple
PIDFile=/var/run/$SPAWN_FCGI_PROG.pid
EnvironmentFile=$SPAWN_FCGI_CONFIG
ExecStart=$SPAWN_FCGI_EXEC -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

    echo "Unit $unit was created."
}

function start_spawn_fcgi {
    systemctl start $SPAWN_FCGI_PROG
    systemctl status $SPAWN_FCGI_PROG
}


install_requirements

prepare_spawn_fcgi_config

create_spawn_fcgi_unit

start_spawn_fcgi