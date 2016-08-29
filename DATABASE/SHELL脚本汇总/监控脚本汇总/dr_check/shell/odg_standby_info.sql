connect / as sysdba
set head off;
set newpage none
set RECSEP off
set trim on
SET FEEDBACK OFF
set TRIMSPOOL on
spool $HOME/dr_check/standby_last.time
select to_char(max(a.first_time),'yyyy-mm-dd hh24:mi:ss') last_apply_time from v$log_history a;
spool off;
spool $HOME/dr_check/standby_last.seq
select ltrim(max(a.sequence#)) last_apply_seq from v$log_history a ;
spool off;
spool $HOME/dr_check/standby_log.dest
select ltrim(max(a.DESTINATION)) log_dest from v$archive_dest a where TARGET='LOCAL' and STATUS='VALID';
spool off;
exit;
