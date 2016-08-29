conn / as sysdba
set  head off 
set newpage  none 
set RECSEP off 
set trim  on 
set flashback off   
set trimspool  on 
spool db_role.txt 
select  database_role from v$database  ; 
spool off 
spool db_status.txt 
select  status from  v$instance  ; 
spool  off 
spool db_version.txt 
select * from  v$version 
spool  off 
spool archive_dest.txt 
select case  when instr(value.'=',1) > 1 then  lower(rtrim(subStr(value,instr(value,'=',1)+1))) else  lower(value) end value
from  v$parameter  where  name  in  ('db_recovery_file_dest','log_archive_dest_1')  and value is not  null and 
(value like '%/%' or  value like '%+%');
spool off 
spool db_name.txt 
select dbid from  v$database  ; 
spool off 
spool fra_usage.txt 
select 'FRA_SIZE',value/1024 size_kb from v$parameter where name='db_recovery_file_dest_size';
select 'FRA_USAGE', round (sum(percent_space_used)) from v$flash_recovery_area_usage;
spool off 
spool asm_usage.txt 
select 'ASM_SIZE',total_mb *1024 from v$asm_diskgroup where name  in 
(
select case when instr(value,'=',1) > 1 then upper(rtrim(subStr(value,instr(value,'+',1)+1)))
else upper (rtrim(subStr(value,instr(value,'+',1)+1))) end value 
from v$parameter  where  name in  ('db_recovery_file_dest', 'log_archive_dest_1') and  value is not null  and 
	(value like  '%/%' or value like  '%+%')
);
select 'ASM_USAGE',round ((total_mb - free_mb)*100 /total_mb)
from v$asm_diskgroup where  name in  
(
select case when instr(value,'=',1) > 1 then upper(rtrim(subStr(value,instr(value,'+',1)+1)))
else upper (rtrim(subStr(value,instr(value,'+',1)+1))) end value 
from v$parameter  where  name in  ('db_recovery_file_dest', 'log_archive_dest_1') and  value is not null  and 
	(value like  '%/%' or value like  '%+%')
);
spool off 
spool is_use_fra.txt
select count(*) from v$parameter  where name ='log_archive_dest_1' and upper(value) like  '%USE_DB_RECOVERY_FILE_DEST%';
spool  off ; 
exit 