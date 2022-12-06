# acs-il-data-guard-oracle-user
Oracle database data guard automation // from the oracle user


## Use this guide / scripts only for testing and learning purpose

## Run the prep script
```
./100_prep_dg_files.sh [ ORACLE_SID ] [ STANDBY UNIQUE NAME ] [ PRIMARY_HOSTNAME ] [ STANDBY_HOSTNAME ]
```

---
## Prerequisites for the data guard creation

* Oracle RDBMS Instance up & running on the primary
* Open port between the servers (default 1521)
* Oracle RDBMS software installed on both primary and standby (Oracle client installation is not enough - you need the database server software installation)
* Copy the password file from the primary to the secondary ($ORACLE_HOME/dbs)
* You should be able to connect as sysdba @ the primary from the standby (I recommend not to run the script until you connect successfully)
* Put the sys password on this environment variable: SYS_PASSWORD (set it on oracle_rdbms_config_sample.conf at the original location you cloned into or comment this line if you set it outside)

## Example how to make sure port 1521 in open  

```  
sudo iptables -I INPUT -p tcp --dport 1521 -j ACCEPT -m comment --comment "Allow remote desktop"

```  

## open the passive FTP option for the password file copy (optional)
```
sudo setsebool ftpd_use_passive_mode on

```

## Steps on the creation process

### On the primary

* enable archive log mode
* enable force logging
* create standby redo logs
* TNS - setup entries for primary and standby -> tnsnames.ora and listener.ora
* start the data guard broker

### On the standby

* TNS - setup entries for primary and standby -> tnsnames.ora and listener.ora
* create directories for the database restore
* prepare init.ora for the restore
* startup nomount with the init.ora
* run RMAN duplicate target
* start the data guard broker
* run the dgmgrl -    
  * create configuration
  * add database
  * enable configuration  

### Test with switchover between the primary and the standby (and back)  

#### You can configure the ORACLE_HOME and ORACLE_BASE on this file:    
[scripts/oracle_rdbms_config_sample.conf](https://github.com/yanivharpaz/ACS-IL-Oracle-RDBMS-Data-Guard/blob/main/scripts/oracle_rdbms_config_sample.conf)


### Usage example on YouTube: https://youtu.be/5xYJvy7Pvgc
### With a different ORACLE_HOME: https://youtu.be/L0cY2xxIA6I
### With a different ORACLE_HOME and without root or sudo: https://youtu.be/CTnZcVd0e-c  


---
Thank you for reading.  
  
You can contact me at http://www.twitter.com/w1025
  
