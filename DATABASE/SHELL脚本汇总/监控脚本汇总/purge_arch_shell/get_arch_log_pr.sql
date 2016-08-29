conn /as sysdba
set linesize 200
set head off
set newpage none
set RECSEP off
set trim on
SET FEEDBACK OFF
set TRIMSPOOL on
spool get_arch_log.txt
  select a.sequence# ,
        round((a.blocks * a.block_size) / 1024) log_kb,
        case when thread#=2 then 'ARCHLOG2_SEQ_' else 'ARCHLOG_SEQ_' end || a.sequence# || '.log' ,thread#
   from v$archived_log a,
        v$archive_dest c
  where 
     a.DEST_ID = c.DEST_ID
    and c.STATUS = 'VALID'
    and c.TARGET = 'PRIMARY'
    and a.resetlogs_time >= (select resetlogs_time from v$database)
    and a.deleted = 'NO'
  order by a.first_time;
spool off
exit