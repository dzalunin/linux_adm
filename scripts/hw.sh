#!/bin/bash

ENV_FILE="/etc/sysconfig/watchlog"
SCRIPT_FILE="/opt/watchlog.sh"
SERVICE_NAME="watchlog"

# Dedug
# rm -f /etc/sysconfig/watchlog /opt/watchlog.sh /etc/systemd/system/watchlog.timer /etc/systemd/system/watchlog.service


function init_config {
    if [ -e $ENV_FILE ]; then
        return 1
    fi

    config_dir="`dirname "${ENV_FILE}"`"
    mkdir -p "${config_dir}"
    cat << EOF > $ENV_FILE
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF

    echo "Default config $ENV_FILE was initialazed."
}


function init_watchlog_script {
    if [ -e $SCRIPT_FILE ]; then
        return 1
    fi
    cat << EOF > $SCRIPT_FILE
#!/bin/bash

WORD=\$1
LOG=\$2
DATE=\`date\`

echo "Run at \$DATE: with WORD=\$1, LOG=\$2"

if grep \$WORD \$LOG &> /dev/null
then
logger "\$DATE: I found word, Master!"
else
exit 0
fi
EOF

    chmod +x $SCRIPT_FILE

    echo "Watchlog script $SCRIPT_FILE was created."
}

function create_service  {
    service_file=/etc/systemd/system/${SERVICE_NAME//'"'/}.service
    if [ -e $service_file ]; then
        return
    fi

    cat << EOF > $service_file
[Unit]
Description=My $SERVICE_NAME service

[Service]
Type=oneshot
EnvironmentFile=$ENV_FILE
ExecStart=$SCRIPT_FILE \$WORD \$LOG
EOF

    echo "Unit $service_file was created."
}


function create_timer {
    timer=${SERVICE_NAME//'"'/}.timer
    timer_file=/etc/systemd/system/$timer
    if [ -e $timer_file ]; then
        return
    fi
    
    service=${SERVICE_NAME//'"'/}.service

    cat << EOF > $timer_file
[Unit]
Description=Run $SERVICE_NAME script every 30 second
Requires=$service

[Timer]
OnUnitActiveSec=30
Unit=$service

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl start $timer

    echo "Timer $timer_file was created."    
}


# Init default config file
init_config

# Create script file
init_watchlog_script

# Create systemd unit and timer for it
create_service && create_timer

# Unit was created succesfully
exit 0
