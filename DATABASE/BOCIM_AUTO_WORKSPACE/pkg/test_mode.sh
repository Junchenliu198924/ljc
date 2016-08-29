#!/bin/bash
sqlplus -S  /nolog <<EOF
set heading off feedback off pagesize 0 verify off echo off
connect task_admin/task_admin@prod1
@t1p1.pkg
commit ;
@t1p2.pkg
commit;
@t1p3.pkg
commit ;
exit  
EOF 
