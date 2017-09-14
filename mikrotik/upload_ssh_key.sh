#!/bin/bash
. ~/bash.conf/routers.conf

# accounts
mtik_usr='admin'
mtik_pwd='!q@s#c$5'

function ftp_upload {
  # $1 => rtr/name
  echo "Uploading id_rsa.pub to $1 ..."
  ncftpput -u $mtik_usr -p $mtik_pwd ${rkey[$1]} . ~/.ssh/id_rsa.pub
}

if [[ "$#" != 0 ]]
then
  for i in "$@"
  do
    if [[ "${rkey[$i]+isset}" ]]
    then
      ftp_upload $i
      echo "Press any key to continue..."
      read
    fi
  done
else
  for i in ${!rkey[@]}
  do
    ftp_upload $i
    echo "Press any key to continue..."
    read
  done
fi
