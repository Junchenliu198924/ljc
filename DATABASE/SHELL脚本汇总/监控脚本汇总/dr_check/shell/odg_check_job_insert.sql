connect drcheck/oracle@drdb
set echo on
set serveroutput on
insert  into drcheck_job_check values ('&3',sysdate,'&1','&2');
commit ;
exit;
