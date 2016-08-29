echo "------------------------begin delete archive log -------------------"
date
cd $HOME/purge_arch_shell
SCRIPT_PATH=$HOME/purge_arch_shell
OSNAME=`uname`
case $OSNAME in
  SunOS) OSNAME=1 ;;
  AIX) OSNAME=2 ;;
  Linux) OSNAME=3 ;;
esac
if [ $OSNAME -eq 3 ]
then
  . $HOME/.bash_profile
else
  . $HOME/.profile
fi

export LANG=en
STARTUP_VALUE=`cat rman.para|grep STARTUP_VALUE|awk -F"=" '{print $2}'`
RESERVE_VALUE=`cat rman.para|grep RESERVE_VALUE|awk -F"=" '{print $2}'`

$ORACLE_HOME/bin/sqlplus /nolog @${SCRIPT_PATH}/get_db_info.sql >/dev/null 2>&1
db_role=`cat db_role.txt|awk '{print $1}'`
db_status=`cat db_status.txt`
ARCDEST=`cat archive_dest.txt`
db_name=`cat db_name.txt`
is_fra=`cat is_use_fra.txt`
is_asm=`cat archive_dest.txt|grep +|wc -l`

if [ $is_fra -eq 0 ]
 then
  if [ $is_asm -eq 0 ]
   then
    echo "not fra managed , is filesystem"
    if [ $OSNAME -eq 1 ]
    then
    fra_usage=`df -k $ARCDEST |grep % |awk '{print $5}'|sed 's/Available/%/g'|cut -f1 -d%`
    fra_size=`df -k $ARCDEST |grep % |awk '{print $2}'|sed 's/Filesystem/%/g'|cut -f1 -d%`
    release_per=`expr $fra_usage - $RESERVE_VALUE`
    release_size=`expr $fra_size \* $release_per \/ 100`
    
    elif [ $OSNAME -eq 2 ]
    then
    fra_usage=`df -k $ARCDEST |grep % |awk '{print $4}' |cut -f1 -d%`
    fra_size=`df -k $ARCDEST |grep %|awk '{print $2}'|sed 's/1024-blocks//g'` 
    release_per=`expr $fra_usage - $RESERVE_VALUE`
    release_size=`expr $fra_size \* $release_per \/ 100`
    
    elif [ $OSNAME -eq 3 ]
    then
    fra_usage=`df -k $ARCDEST |grep % |awk '{print $5}'|sed 's/Use/%/g'|cut -f1 -d%`
    fra_size=`df -k $ARCDEST |grep % |awk '{print $2}'|sed 's/1K-blocks/%/g'|cut -f1 -d%`
    release_per=`expr $fra_usage - $RESERVE_VALUE`
    release_size=`expr $fra_size \* $release_per \/ 100`
    fi

  else
   echo "not fra managed , is asm managed"
   fra_usage=`cat asm_usage.txt|grep ASM_USAGE|awk '{print $2}'`
   fra_size=`cat asm_usage.txt|grep ASM_SIZE|awk '{print $2}'`
   release_per=`expr $fra_usage - $RESERVE_VALUE`
   release_size=`expr $fra_size \* $release_per \/ 100`
   
  fi
else
   echo "is fra managed"
   fra_usage=`cat fra_usage.txt|grep FRA_USAGE|awk '{print $2}'`
   fra_size=`cat fra_usage.txt|grep FRA_SIZE|awk '{print $2}'`
   release_per=`expr $fra_usage - $RESERVE_VALUE`
   release_size=`expr $fra_size \* $release_per \/ 100`
fi

echo "fra_size $fra_size"
echo "fra_usage $fra_usage"
echo "release_per $release_per"
echo "release_size $release_size"

if [ $fra_usage -ge $STARTUP_VALUE ]
then
        :>del_arch_log.ram
	if [ $db_role = "PRIMARY" ]
	  then
			$ORACLE_HOME/bin/sqlplus /nolog @${SCRIPT_PATH}/get_arch_log_pr.sql >/dev/null 2>&1
	elif 	[ $db_role = "PHYSICAL" ]
		then
			$ORACLE_HOME/bin/sqlplus /nolog @${SCRIPT_PATH}/get_arch_log_st.sql >/dev/null 2>&1
	fi
	
	cat get_arch_log.txt | awk '{print $3}' | while read LINE
 	do
   				if [ $release_size -gt 0 ]
   					then
   						SEQ=`cat get_arch_log.txt|grep $LINE| awk '{print $1}'`
   						log_size=`cat get_arch_log.txt|grep $LINE| awk '{print $2}'`
   						THREAD=`cat get_arch_log.txt|grep $LINE| awk '{print $4}'`

              release_size=`expr $release_size - $log_size`
			
              echo "delete noprompt archivelog sequence $SEQ thread $THREAD ;" >>del_arch_log.ram
              
     			else
   						break
   				fi	 
 	done
 	
        echo "run {" > del_arch_log_until_seq.ram
 	cat del_arch_log.ram |grep sequence |awk '{print $7}' |sort -n |uniq | while read LINE
        do
             max_sql=`cat del_arch_log.ram |grep "thread $LINE" |awk '{print $5}' |sort -n |uniq |sed -n '$p'`
             echo "delete noprompt archivelog until sequence $max_sql thread $LINE ;" >>del_arch_log_until_seq.ram
        done
        echo "}" >> del_arch_log_until_seq.ram

 	$ORACLE_HOME/bin/rman target / cmdfile=del_arch_log_until_seq.ram >>rman_del_arch.log

fi
date
echo "------------------------end delete archive log -------------------"
