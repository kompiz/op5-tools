#!/bin/bash

MONITOR_USER=foo
MONITOR_PASSWORD=bar
MONITOR_SERVER=foobar

HOSTNAME=$(hostname)

# Add localhost:
curl -H "Accept: application/json" -H 'content-type: application/json' -X POST -d '{ "file_id": "etc/hosts.cfg", "host_name": '\"$HOSTNAME\"', "max_check_attempts": "3", "notification_interval": "5", "notification_options": ["d","r"], "notification_period": "24x7", "template": "default-host-template"}' "https://$MONITOR_SERVER/api/config/host" -u "$MONITOR_USER:$MONITOR_PASSWORD"


# Declare service arrays
SERVICE[0]=PING
COMMAND[0]=check_ping
COMMAND_ARGS[0]="100,20%!500,60%"

SERVICE[1]="Current users"
COMMAND[1]=check_nrpe
COMMAND_ARGS[1]=users

SERVICE[2]="Cron process"
COMMAND[2]=check_nrpe
COMMAND_ARGS[2]=proc_crond

SERVICE[3]="Disk usage /"
COMMAND[3]=check_nrpe
COMMAND_ARGS[3]=root_disk

SERVICE[4]="Disk usage /boot"
COMMAND[4]=check_nrpe
COMMAND_ARGS[4]=boot_disk

SERVICE[5]="Puppet agent process hänger"
COMMAND[5]=check_nrpe
COMMAND_ARGS[5]=proc_puppet

SERVICE[6]="Rsyslog process"
COMMAND[6]=check_nrpe
COMMAND_ARGS[6]=prod_rsyslogd

SERVICE[7]="SSH Server"
COMMAND[7]=check_ssh
COMMAND_ARGS[7]=5

SERVICE[8]="Swap usage"
COMMAND[8]=check_nrpe
COMMAND_ARGS[8]=swap

SERVICE[9]="System Load"
COMMAND[9]=check_nrpe
COMMAND_ARGS[9]=load

SERVICE[10]="Total processes"
COMMAND[10]=check_nrpe
COMMAND_ARGS[10]=total_procs

SERVICE[11]="Zombie processes"
COMMAND[11]=check_nrpe
COMMAND_ARGS[11]=zombie_procs

#Add checks
counter=0
for i in "${SERVICE[@]}";
do
    curl -H 'content-type: application/json' -d '{"file_id": "etc/services.cfg", "check_command": "'"${COMMAND[$counter]}"'", "check_command_args": "'"${COMMAND_ARGS[$counter]}"'", "check_interval": "5", "check_period": "24x7", "host_name": '\"$HOSTNAME\"', "max_check_attempts": "3", "notification_interval": "0", "notification_options": ["c", "w", "u", "r"], "notification_period": "24x7", "retry_interval": "1", "service_description": "'"${SERVICE[$counter]}"'", "template": "default-service"}' "https://$MONITOR_SERVER/api/config/service" -u "$MONITOR_USER:$MONITOR_PASSWORD"
    (( counter++ ))
done

# Save to OP5-server
curl -H 'content-type: application/json' -X POST -u "$MONITOR_USER:$MONITOR_PASSWORD" "https://$MONITOR_SERVER/api/config/change"
