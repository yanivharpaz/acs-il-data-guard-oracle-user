#!/bin/bash
#

# if [ $# -ne 1 ]
# then
#     echo "Usage: sudo $0 [ ORACLE_SID ] "
#     exit 1
# fi


echo "Reading configuration 300"
NEW_CONFIG_NAME="oracle_rdbms_config_sample.conf"
NEW_CONFIGURATION="/tmp/$NEW_CONFIG_NAME"

. "$NEW_CONFIGURATION" $ORACLE_SID

echo "ORACLE_HOME       : $ORACLE_HOME"
echo "ORACLE_SID        : $ORACLE_SID"

# General exports and vars
export PATH=$ORACLE_HOME/bin:$PATH
LSNR=$ORACLE_HOME/bin/lsnrctl
SQLPLUS=$ORACLE_HOME/bin/sqlplus
DBCA=$ORACLE_HOME/bin/dbca
NETCA=$ORACLE_HOME/bin/netca
ORACLE_OWNER=oracle
RETVAL=0
#CONFIG_NAME="oracledb_$ORACLE_SID-$ORACLE_VERSION.conf"
#CONFIGURATION="/etc/sysconfig/$CONFIG_NAME"

NEW_CONFIG_NAME="oracle_rdbms_config_sample.conf"
NEW_CONFIGURATION="/tmp/$NEW_CONFIG_NAME"

. "$NEW_CONFIGURATION"

# Commands
if [ -z "$SU" ];then SU=/bin/su; fi
if [ -z "$GREP" ]; then GREP=/usr/bin/grep; fi
if [ ! -f "$GREP" ]; then GREP=/bin/grep; fi


run_scripts_standby() {
    /bin/bash -c "/tmp/112_open_port.sh $LISTENER_PORT"

    /bin/bash -c "/tmp/410_copy_tns_files_standby.sh"
    /bin/bash -c "/tmp/110_restart_listener.sh"

    /bin/bash -c "/tmp/420_ora_dg_mkdir.sh"
    # /bin/bash -c "/tmp/430_ora_dg_orapwd.sh"
    /bin/bash -c "/tmp/440_startup_nomount.sh"
    /bin/bash -c "/tmp/450_rman_connect_and_restore.sh"
    /bin/bash -c "/tmp/120_dg_broker_start.sh"

    /bin/bash -c "/tmp/470_dgmgrl_config.sh"
    /bin/bash -c "/tmp/show_config.sh"
    sleep 10
    /bin/bash -c "/tmp/show_config.sh"

}

#prep_dg_01
#cat /tmp/prep_dg.log

run_scripts_standby

exit 0
