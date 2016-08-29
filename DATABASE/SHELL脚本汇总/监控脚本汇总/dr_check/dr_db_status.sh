#!/usr/bin/ksh
echo '**********test start**********'
cd $HOME
.  ./.profile
checkdate=`date +%Y%m%d`
if [-d dr_check]
then
          echo "$HOME/dr_check/shell存在"
else
                mkdir -p $HOME/dr_check
          echo "已经创建指定目录"
fi
dr_ip="$1"
info_step="*********begin to check $ORACLE_SID  on $dr_ip**********"
echo $info_step
sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step" $checkdate
info_step="step1-check $ORACLE_SID status**********"
sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step" $checkdate
#step1 check db status
check=`ps -ef |grep ora_smon_$ORACLE_SID|grep -v grep|wc -l`
if [ $check -eq 0 ]
then
        info_step_1="step1-1:standby database $ORACLE_SID closed"
        sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
  info_step_1="step1-2:begin to mount it!"
  sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
  sqlplus /nolog @$HOME/dr_check/shell/odg_start_mount.sql
  sqlplus /nolog    @$HOME/dr_check/shell/odg_standby_info.sql
  P_LAST_LOG_DEST=`cat $HOME/dr_check/standby_log.dest`
  info_step_1="step1-2:The standby log destination is:$P_LAST_LOG_DEST"
  sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
  P_LAST_APPLY_SEQ=`cat  $HOME/dr_check/standby_last.seq`
  info_step_1="step1-2:The standby last log sequence is :$P_LAST_APPLY_SEQ"
  sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
  P_LAST_APPLY_TIME=`cat  $HOME/dr_check/standby_last.time`
  info_step_1="step1-2:The standby last apply time is:$P_LAST_APPLY_TIME"
else
  sqlplus /nolog    @$HOME/dr_check/shell/odg_standby_status.sql
  P_LAST_DG_STATUS=`cat  $HOME/dr_check/standby_status.lst`
  info_step_1="standby database $ORACLE_SID is $P_LAST_DG_STATUS"
  sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
  echo $P_LAST_DG_STATUS
  if [ $P_LAST_DG_STATUS = MOUNTED ] || [ $P_LAST_DG_STATUS = OPEN ]
  then
       info_step_1="step1-2:collect standby database info"
       sqlplus /nolog    @$HOME/dr_check/shell/odg_standby_info.sql
       P_LAST_LOG_DEST=`cat  $HOME/dr_check/standby_log.dest`
       info_step_1="step1-2:The standby log destination is:$P_LAST_LOG_DEST"
       sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
       P_LAST_APPLY_SEQ=`cat  $HOME/dr_check/standby_last.seq`
       info_step_1="step1-2:The standby last log sequence is:$P_LAST_APPLY_SEQ"
       sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
       P_LAST_APPLY_TIME=`cat  $HOME/dr_check/standby_last.time`
       info_step_1="step1-2:The standby last apply time is:$P_LAST_APPLY_TIME"
       sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
       sqlplus /nolog @$HOME/dr_check/shell/odg_get_recovery_dest.sql
       P_DB_RECOVERY_DEST=`cat $HOME/dr_check/show_recovery.lst|grep db_recovery_file_dest|grep -v size|awk '{print $3}'`
       P_DB_RECOVERY_USED=` df -g |grep  -i  $P_DB_RECOVERY_DEST|awk '{print $4}'`
       info_step_1="step1-2:The standby archive log dest is:$P_DB_RECOVERY_DEST"
       sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
       info_step_1="step1-2:The standby archive log dest used percent:$P_DB_RECOVERY_USED"
       sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
       P_HOSTNAME=`hostname`
       info_step_1="step1-2:The standby hostname is:$P_HOSTNAME"
       sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
###begin endi##
##begin 判断oracle的版本
VER9=`echo 'select * from v$version;' | sqlplus -S $TNS_STRING|grep -i Oracle9i|wc -l`
VER10=`echo 'select * from v$version;' | sqlplus -S $TNS_STRING|grep -i '10.1.'|wc -l`
get_dg_dbfiles_status()
{
sqlplus -S '/ as sysdba' <<EOF
set pages 0 termout off verify off feedback off
var v_offline_num varchar2(200);
var v_active_num varchar2(200);
var v_apply_lag varchar2(200);
var v_time_computed varchar2(200);
select count(1) into :v_offline_num from v\$datafile where status='OFFLINE';
select count(1) into :v_active_num from v\$backup where status='ACTIVE';
select value,time_computed  into :v_apply_lag,:v_time_computed from v\$dataguard_stats where name='apply lag' ;
/
print v_offline_num
print v_active_num
print v_apply_lag
print v_time_computed
exit
EOF
}
get_9i_dg_dbfiles_status()
{
sqlplus -S '/ as sysdba' <<EOF
set pages 0 termout off verify off feedback off
var v_offline_num varchar2(200);
var v_active_num varchar2(200);
select count(1) into :v_offline_num from v\$datafile where status='OFFLINE';
select count(1) into :v_active_num from v\$backup where status='ACTIVE';
/
print v_offline_num
print v_active_num
exit
EOF
}
 if [ $VER9 -gt 0 ]|| [ $VER10R1 -gt 0 ]
 then
 TMP=`get_9i_dg_dbfiles_status`
 P_OFFLINE_NUM=`echo $TMP|awk '{print $1}'`
 echo $P_OFFLINE_NUM
 info_step_1="step1-2:The standby OFFLINE_NUM is:$P_OFFLINE_NUM"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 P_ACTIVE_NUM=`echo $TMP|awk '{print $2}'`
 info_step_1="step1-2:The standby bk_ACTIVE_NUM is:$P_ACTIVE_NUM"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 P_APPLY_LAG=''
 info_step_1="step1-2:The standby APPLY_LAG is:9ican not get"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 P_TIME_COMPUTED=''
 info_step_1="step1-2:The standby TIME_COMPUTED is:9ican not get"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 else
 TMP=`get_dg_dbfiles_status`
 echo $TMP
 P_OFFLINE_NUM=`echo $TMP|awk '{print $1}'`
 info_step_1="step1-2:The standby OFFLINE_NUM is:$P_OFFLINE_NUM"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 P_ACTIVE_NUM=`echo $TMP|awk '{print $2}'`
 info_step_1="step1-2:The standby ACTIVE_NUM is:$P_ACTIVE_NUM"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 P_APPLY_LAG=`echo $TMP|awk '{print $3,$4}'`
 info_step_1="step1-2:The standby APPLY_LAG is:$P_APPLY_LAG"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 P_TIME_COMPUTED=`echo $TMP|awk '{print $5,$6}'`
 info_step_1="step1-2:The standby TIME_COMPUTED is:$P_TIME_COMPUTED"
 sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
 fi
###begin end##
##begin to insert alert log##
sqlplus /nolog    @$HOME/dr_check/shell/odg_bdump_dest.sql
bdump_dest=`cat $HOME/dr_check/bdump_dest.lst`
echo "bdump_dest"
echo "$bdump_dest"
tail -10 $bdump_dest/alert*>$HOME/dr_check/db_alert.log
cat $HOME/dr_check/db_alert.log|sed "s/\'/|/g"|sed 's/#/|/g' >$HOME/dr_check/db_alert.log
serial=1
while read LINE
do
alertlog=`echo  $LINE`
sqlplus /nolog   @$HOME/dr_check/shell/odg_alert_insert.sql "$checkdate"  "$ORACLE_SID" "$alertlog"  "$serial"
serial=$(($serial+1))
done < $HOME/dr_check/db_alert.log
##begin to insert into  check db!
info_step_2="begin to insert parameter into check db!"
sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_2" $checkdate
sqlplus  /nolog   @$HOME/dr_check/shell/odg_parameter_insert.sql $ORACLE_SID  "$P_LAST_LOG_DEST" "$P_LAST_APPLY_SEQ" "$P_LAST_APPLY_TIME" "$P_DB_RECOVERY_DEST"  "$P_DB_RECOVERY_USED" "$P_HOSTNAME" "$P_OFFLINE_NUM" "$P_ACTIVE_NUM" "$P_APPLY_LAG" "$P_TIME_COMPUTED" "$dr_ip" "$P_LAST_DG_STATUS"
info_step_3="**********check end**********"
sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_3" $checkdate
  else
     info_step_1="standby database not mount or open,please check db hosts!"
     sqlplus  /nolog   @$HOME/dr_check/shell/odg_check_job_insert.sql $ORACLE_SID "$info_step_1" $checkdate
  fi
fi
