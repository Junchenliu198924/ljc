connect / as sysdba
set head off;
set newpage none
set RECSEP off
set trim on
SET FEEDBACK OFF
set TRIMSPOOL on
spool $HOME/dr_check/bdump_dest.lst
 select value from    v$parameter  where    name= ('background_dump_dest');
 spool off;
exit;
