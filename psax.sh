#!/bin/bash

# Гарантируем, что скрипт завершит работу, как только он встретит
# - любой ненулевой код завершения,
# - использование неопределенных переменных,
# - неправильные команды, переданные по каналу
set -o errexit
set -o nounset
set -o pipefail

format_string="%-5s %-5s %-5s %-10s %-30s\n"

clock_ticks=$(getconf CLK_TCK)
uptime=`awk -F" " '{print $1}' /proc/uptime`

printf "$format_string" PID TTY STAT TIME COMMAND
for stat_file in `find /proc/ -type f -regex '\/proc\/[0-9]*\/stat'`; do
    if [ ! -f $stat_file ]; then
        continue
    fi

    stat=(`sed -E 's/(\([^\s)]+)\s([^)]+\))/\1_\2/g' $stat_file`)

    # The process ID. 
    pid=${stat[0]}

    # This read-only file holds the complete command line for
    # the process, unless the process is a zombie.  In the
    # latter case, there is nothing in this file: that is, a
    # read on this file will return 0 characters.  The command-
    # line arguments appear in this file as a set of strings
    # separated by null bytes ('\0'), with a further null byte
    # after the last string. 
    command=`(cat /proc/$pid/cmdline | sed -e 's/\x00//g')`
    if [ -z "$command" ]; then
        # The filename of the executable, in parentheses.
        # Strings longer than TASK_COMM_LEN (16) characters
        # (including the terminating null byte) are silently
        # truncated.  This is visible whether or not the
        # executable is swapped out.
        command=${stat[1]}
    fi

    # One of the following characters, indicating process
    # state:
    # R  Running
    # S  Sleeping in an interruptible wait
    # D  Waiting in uninterruptible disk sleep
    # Z  Zombie
    # T  Stopped (on a signal) or (before Linux 2.6.33)
    # trace stopped
    # t  Tracing stop (Linux 2.6.33 onward)
    # W  Paging (only before Linux 2.6.0)
    # X  Dead (from Linux 2.6.0 onward)
    # x  Dead (Linux 2.6.33 to 3.13 only)
    # K  Wakekill (Linux 2.6.33 to 3.13 only)
    # W  Waking (Linux 2.6.33 to 3.13 only)
    # P  Parked (Linux 3.9 to 3.13 only)
    state=${stat[2]}

    # The controlling terminal of the process.  (The
    # minor device number is contained in the combination
    # of bits 31 to 20 and 7 to 0; the major device
    # number is in bits 15 to 8.)
    tty=${stat[6]}

    # Amount of time that this process has been scheduled
    # in user mode, measured in clock ticks (divide by
    # sysconf(_SC_CLK_TCK)).  This includes guest time,
    # guest_time (time spent running a virtual CPU, see
    # below), so that applications that are not aware of
    # the guest time field do not lose that time from
    # their calculations.
    utime=$((${stat[14]} / $clock_ticks))

    # Amount of time that this process has been scheduled
    # in kernel mode, measured in clock ticks (divide by
    # sysconf(_SC_CLK_TCK)).
    stime=$((${stat[15]} / $clock_ticks))

    time=$(($utime + $stime))

    printf "$format_string" $pid $tty $state $time $command
done