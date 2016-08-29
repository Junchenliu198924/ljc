connect drcheck/oracle@drdb
set echo on
set serveroutput on
insert  into db_alert_log_d values ('&1','&2','&3','&4',sysdate);
commit ;
exit;
