connect / as sysdba
set head off;
set newpage none
set RECSEP off
set trim on
SET FEEDBACK OFF
set TRIMSPOOL on
spool $HOME/dr_check/standby_status.lst
select STATUS from v$instance;
spool off;
exit;

