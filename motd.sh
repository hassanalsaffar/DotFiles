#!/usr/bin/bash

clear

function color (){
  echo "\e[$1m$2\e[0m"
}

function extend (){
  local str="$1"
  let spaces=60-${#1}
  while [ $spaces -gt 0 ]; do
    str="$str "
    let spaces=spaces-1
  done
  echo "$str"
}

function center (){
  local str="$1"
  let spacesLeft=(78-${#1})/2
  let spacesRight=78-spacesLeft-${#1}
  while [ $spacesLeft -gt 0 ]; do
    str=" $str"
    let spacesLeft=spacesLeft-1
  done
  
  while [ $spacesRight -gt 0 ]; do
    str="$str "
    let spacesRight=spacesRight-1
  done
  
  echo "$str"
}

function sec2time (){
  local input=$1
  
  if [ $input -lt 60 ]; then
    echo "$input seconds"
  else
    ((days=input/86400))
    ((input=input%86400))
    ((hours=input/3600))
    ((input=input%3600))
    ((mins=input/60))
    
    local daysPlural="s"
    local hoursPlural="s"
    local minsPlural="s"
    
    if [ $days -eq 1 ]; then
      daysPlural=""
    fi
    
    if [ $hours -eq 1 ]; then
      hoursPlural=""
    fi
    
    if [ $mins -eq 1 ]; then
      minsPlural=""
    fi
    
    echo "$days day$daysPlural, $hours hour$hoursPlural, $mins minute$minsPlural"
  fi
}

borderColor=31
greetingsColor=36
statsLabelColor=33
textColor=37

borderLine="+----------------------------------------------------------------------+"
borderBottomLine=$(color $borderColor "$borderLine")
borderEmptyLine=" "

# Header

me=$(whoami)

# Greetings
notice="$(color $greetingsColor "$(center "Welcome back, $me!")")\n"
notice="$greetings$(color $greetingsColor "$(center "$(date +"%A, %d %B %Y, %T")")")"

# System information
read loginFrom loginIP loginDate <<< $(last $me | awk 'NR==2 { print $2,$3,$4 }')

# TTY login
if [[ $loginDate == - ]]; then
  loginDate=$loginIP
  loginIP=$loginFrom
fi

if [[ $loginDate == *T* ]]; then
  login="$(date -d $loginDate +"%A, %d %B %Y, %T") ($loginIP)"
else
  # Not enough logins
  login="None"
fi

echo -e "$borderBottomLine"
echo
echo -e "$(color $greetingsColor "$(center "** NOTICE TO USERS **")")\n"
echo -e "$(color $textColor "$(center "  This computer system is for authorized use only. Users (authorized\n  or unauthorized) have no explicit or implicit expectation of privacy.\n\n  Any or all uses of this system and all files on this system may be\n  intercepted, monitored, recorded, copied, audited, inspected,\n  and disclosed to authorized site and law enforcement personnel.\n\n  By using this system, the user consents to such interception,\n  monitoring, recording, copying, auditing, inspection, and disclosure\n  at the discretion of the authorized site.\n\n  Unauthorized or improper use of this system may result in\n  administrative disciplinary action and civil and criminal penalties.\n  By continuing to use this system you indicate your awareness of\n  and consent to these terms and conditions of use.\n\n  LOG OFF IMMEDIATELY if you do not agree to the conditions stated\n  in this warning.")")\n"
echo -e "$borderBottomLine"

label1="$(extend "$login")"
label1="  $(color $statsLabelColor "Last Login....:") $label1"

uptime="$(sec2time $(cut -d "." -f 1 /proc/uptime))"
uptime="$uptime ($(date -d "@"$(grep btime /proc/stat | cut -d " " -f 2) +"%d-%m-%Y %H:%M:%S"))"

label2="$(extend "$uptime")"
label2="  $(color $statsLabelColor "Uptime........:") $label2"

label10="$(cat /etc/redhat-release)"
label10="  $(color $statsLabelColor "OS Release....:") $label10"

ram="$(cat /proc/meminfo | grep MemTotal | awk '{print $2/(1024^2)}')"
cpu="$(cat /proc/cpuinfo | grep -c processor)"
cpuChip="$(cat /proc/cpuinfo | grep "model name" | head -1 | awk -F ":" '{print $2}')"
label8="  $(color $statsLabelColor "Config Model..:") $cpu CPU Cores ($cpuChip) x $ram GB RAM"

label9="$(uptime | grep -ohe '[s:][: ].*' | awk '{ print "1m: "$2 " 5m: "$3 " 15m: " $4}')"
label9="  $(color $statsLabelColor "Load Average..:") $label9"

label3="$(extend "$(free -m | awk 'NR==2 { printf "Total: %sMB, Used: %sMB, Free: %sMB",$2,$3,$4; }')")"
label3="  $(color $statsLabelColor "Memory........:") $label3"

label4="$(extend "$(df -h ~ | awk 'NR==2 { printf "Total: %sB, Used: %sB, Free: %sB",$2,$3,$4; }')")"
label4="  $(color $statsLabelColor "Home space....:") $label4"

LAST_UPDATE=`ls -ltr /etc/snort/rules/*.rules | tail -1 | awk '{print $9}'`
LAST_UPDATE_EPOCH=`date -r $LAST_UPDATE +%s`
SYSDATE_EPOCH=`date +%s`
TIME_DIFF=$(((($SYSDATE_EPOCH - $LAST_UPDATE_EPOCH)) / 86400 ))
label5="$TIME_DIFF days ago"
label5="  $(color $statsLabelColor "Snort Signatures Last Update:") $label5 "

label6="$( get-snort-stats.sh --week | awk -F ":" '{print $2}' | grep Mbps)"
label6="  $(color $statsLabelColor "Average throughput for the last week: ") $label6 "

label7="$( get-snort-stats.sh --week | awk -F ":" '{print $2}' | grep percent)"
label7="  $(color $statsLabelColor "Average dropped packets for the last week: ") $label7 "

stats="$label1\n$label2\n$label10\n$label8\n$label9\n$label3\n$label4\n$label5\n$label6\n$label7"

# Print motd
echo -e "\n$notice\n$borderEmptyLine\n$stats\n$borderEmptyLine\n$borderBottomLine"
