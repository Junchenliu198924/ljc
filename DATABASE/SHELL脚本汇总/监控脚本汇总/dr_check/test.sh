#!/usr/bin/ksh
sqlplus /nolog    @$HOME/dr_check/shell/odg_bdump_dest.sql
bdump_dest=`cat $HOME/dr_check/bdump_dest.lst`
echo "bdump_dest"
echo "$bdump_dest"
tail -10 $bdump_dest/alert*>$HOME/dr_check/db_alert.log
serial=1 
while read LINE
do
alertlog=`echo  $LINE`
sqlplus /nolog   @$HOME/dr_check/shell/odg_alert_insert.sql "20150316"  "WHPRD" "$alertlog"  "$serial"
serial=$(($serial+1))
done < db_alert.log
