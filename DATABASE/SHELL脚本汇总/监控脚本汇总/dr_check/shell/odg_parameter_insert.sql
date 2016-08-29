connect drcheck/oracle@drdb
set echo on
set serveroutput on
insert  into   drcheck.DB_CHECK_AUTO_D   values ('&1','&2','&3','&4','&5','&6','&7','&8','&9','&10','&11',sysdate,'&12','&13');
commit ;
exit;

