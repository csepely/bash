#!/bin/bash

## imports
. ~/bash.conf/routers.conf
. ~/mikrotik/functions.in

for i in ${!rkey[@]}
do
  create_backup ${rkey[$i]}
  download_backup ${rkey[$i]}
done
