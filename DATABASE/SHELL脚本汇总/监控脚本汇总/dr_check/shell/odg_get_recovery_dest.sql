connect / as sysdba
set head off;
set newpage none
set RECSEP off
set trim on
SET FEEDBACK OFF
set TRIMSPOOL on
spool $HOME/dr_check/show_recovery.lst
show   parameter db_recovery;
spool off;
exit;
