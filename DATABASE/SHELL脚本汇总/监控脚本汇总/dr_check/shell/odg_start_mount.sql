connect / as sysdba
startup nomount;
alter database mount standby database;
exit;
