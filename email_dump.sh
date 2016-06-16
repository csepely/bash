#!/bin/bash
function getUserHome {
index="$2"
#cat /etc/passwd | grep -E "^$1:" | while read n;
cat /etc/passwd | grep -E "^$1:" | while read n;
do
  n="${n// /_}"
  n=${n//::/:x:}
  a=(${n//:/ })
  echo -n ${a[$index]}
done
}

function getDate {
  # user dir $1/Maildir/{cur,new}
  u=$(getUserHome $1 5)
  if [[ -d "$u/Maildir/" ]];
  then
#      echo "u = $u"
      dFile=$(ls -t "$u/Maildir/$2/"|head -n 1)
      #echo -n "dFile: $dFile"
      dDate=($(stat "$u/Maildir/$2/$dFile" | grep "Modify"))
      #echo -n "dDate: ${#dDate[@]}"
      echo -n "${dDate[1]};"
  else
    echo -n "-;"
  fi
}

function fwd {
#cat /etc/passwd |grep -E "^$1:"| while read n;
#cat /etc/passwd |grep -E "^$1:"| while read n;
#do
#  echo -n "fwd::<$n>::"
#  n="${n// /_}"
#  n=${n//::/:x:}
#  a=(${n//:/ })
  a=$(getUserHome $1 5)
  if [[ -e "${a}/.forward" ]];
  then
    b=$(cat "${a}/.forward")
    b=${b//,/ }
    b=${b##"\"|/usr/bin/procmail -f-\""}
    b=(${b})
    if [[ "${#b[@]}" != 0 ]];
    then
#      echo -n "${a[0]};";
      for i in ${b[@]};
      do
        echo -n "$i;"
      done
#      echo ""
    else
          echo -n "-;"
    fi
  else
    echo -n "-;"
  fi
#done
}

function eUsers {
cat /etc/postfix/virtusertable|grep -v "^#"| grep -E "(.+)\@([a-z]+)\.hu([ ]+)(.+)$"|while read n;
do
  a=($n)
  e="${a[0]}"
  u="${a[1]}"
  domain="${e#*@}"
  mailbox="${u}@${domain}"
  echo -n "$mailbox;"
#  echo -n "$e;$u;"
#  c=$(getDate "$u" "cur")
#  n=$(getDate "$u" "new")
#  echo -n $c
#  echo -n $n
  fwd "$u"
  echo ""
done
}

function getMailbox {
while read n
do
  a=($n)
  e="${a[0]}"
  u="${a[1]}"
  domain="${e#*@}"
  mailbox="${u}@${domain}"
  if [[ -n "$1" ]]
  then
    uA=${1/@/ }
    uA=($uA)
#    echo "${uA[0]} == $u"
#    echo ${uA[1]}
    if [[ "$e" != "$mailbox" ]] && [[ "${uA[0]}" == "${u}" ]];
    then
      echo -n " $e "
    fi
  else
    if [[ "$e" == "$mailbox" ]];
    then
      echo -n " $mailbox "
    fi
  fi
done < <(cat /etc/postfix/virtusertable | grep -v "^#" | grep -E "^(.+)\@([a-z]+)\.hu([ ]+)(.+)$")
}

function syncMailbox {
  mBoxs=$(getMailbox)
  for i in $mBoxs
  do
    printf -v q "select count(login) from mail_user where login=\'%s\';" $i;
    o=$(ssh -n thief@vps.szerencs.hu -p 10022 "mysql -N -u root --password=e4UHxob1 dbispconfig --execute=\"$q\"");
    if [[ "$o" != 1 ]]
    then
      u=${i%@*}
      e=$i
      clientUser="$u";
      clientDomain="${e#*@}";
      clientName=$(/tmp/email/email_dump.sh getHome $u 4);
      echo "$clientName => $clientUser@$clientDomain";
      read;
      s=$(ssh -n thief@vps.szerencs.hu -p 10022 "cd public_html/ispconfig3_install/remoting_client/examples/tools/;php -f mail_user_add.php 2 $clientUser $clientDomain $clientName;");
      echo $s;
      read;
    fi
  done
}

function syncAlias {
  echo syncAlias
  mBoxs=$(getMailbox)
  for i in $mBoxs
  do
    mBoxAlias=$(getMailbox $i)
    for j in $mBoxAlias
    do
      printf -v q "select count(source) from mail_forwarding where source=\'%s\' and destination=\'%s\' and type=\'alias\'" "$j" "$i"
      s=$(ssh -n thief@vps.szerencs.hu -p 10022 "mysql -N -u root --password=e4UHxob1 dbispconfig --execute=\"$q\"");
      if [[ "$s" -eq 0 ]]
      then
        s=$(ssh -n thief@vps.szerencs.hu -p 10022 "cd public_html/ispconfig3_install/remoting_client/examples/tools/;php -f mail_alias_add.php 2 ${j} ${i}")
        echo "$i => $j ==> $s"
      fi
    done
  done
}

#eUsers
#fwd $1
#getUserHome "cspeter"
#getCurNewDate $1
#dumpMailbox

case "$1" in
    getHome)
        getUserHome $2 $3
    ;;
    getDate)
        getDate
    ;;
    getFwd)
        fwd $2
    ;;
    getUsers)
        eUsers
    ;;
    getMailbox)
        getMailbox
    ;;
    getAlias)
        getMailbox $2
    ;;
    syncMailbox)
      syncMailbox
    ;;
    syncAlias)
      syncAlias
    ;;
    *)
    echo "Usage: $0 [getHome|getDate|getFwd|getUsers|getMailbox|getAlias|syncMailbox|syncAlias]"
    exit 0
esac
