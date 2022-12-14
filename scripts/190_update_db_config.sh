#!/bin/bash
#

# if [ $# -ne 1 ]
# then
#     echo "Usage: sudo $0 [ ORACLE_SID ] "
#     exit 1
# fi
echo "ORACLE_SID       : $ORACLE_SID"
echo "Reading configuration 190"
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

# Commands
if [ -z "$SU" ];then SU=/bin/su; fi
if [ -z "$GREP" ]; then GREP=/usr/bin/grep; fi
if [ ! -f "$GREP" ]; then GREP=/bin/grep; fi

prep_dg_01()
{

    pmon=`ps -ef | egrep pmon_$ORACLE_SID'\>' | $GREP -v grep`
    if [ "$pmon" != "" ];
    then

        echo "Putting Oracle instance in archivelog $ORACLE_SID."
        # $SU -s /bin/bash  $ORACLE_OWNER -c "$SQLPLUS -s /nolog << EOF

        /bin/bash -c "$SQLPLUS -s /nolog << EOF

            connect / as sysdba
            spool /tmp/prep_dg.log
            set echo on
            SELECT log_mode FROM v\\\$database;
            select member from v\\\$logfile;
            alter system set db_recovery_file_dest_size=10G scope=both sid='*';
            alter system set db_recovery_file_dest='$ORACLE_BASE/oradata' scope=both sid='*';
            SHUTDOWN IMMEDIATE;
            STARTUP MOUNT;
            ALTER DATABASE ARCHIVELOG;
            ALTER DATABASE OPEN;
            ALTER DATABASE FORCE LOGGING;
            ALTER SYSTEM SWITCH LOGFILE;
            select 'Oracle SID: $ORACLE_SID' AS SID FROM DUAL;

            ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 ('$ORACLE_REDO_LOCATION/standby_redo01.log') SIZE $STANDBY_REDO_LOG_SIZE;
            ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 ('$ORACLE_REDO_LOCATION/standby_redo02.log') SIZE $STANDBY_REDO_LOG_SIZE;
            ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 ('$ORACLE_REDO_LOCATION/standby_redo03.log') SIZE $STANDBY_REDO_LOG_SIZE;

            ALTER DATABASE FLASHBACK ON;
            ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;

            SELECT log_mode FROM v\\\$database;
            select member from v\\\$logfile;
            spool off
            exit;
EOF" 
        RETVAL1=$?
        if [ $RETVAL1 -eq 0 ]
        then
            echo "Oracle Database instance $ORACLE_SID started."
        fi
    else
        echo "Oracle instance not running $ORACLE_SID."
        exit 0
    fi

    echo
    if [ $RETVAL -eq 0 ] && [ $RETVAL1 -eq 0 ]
    then
        return 0
     else
        echo "Failed to prepare database instance for data guard."
        exit 1
    fi
}

prep_dg_01
cat /tmp/prep_dg.log

exit 0
