function genSnmpConf {
  ip_addr=($1)
  collects=($2)
  collectStr="Collect "
  for i in ${collects[@]}
  do
    collectStr+=" \"$i\""
  done
  for i in ${!ip_addr[@]}
  do
    n=$(snmpget -OQ -Ov -c public -v 1 ${ip_addr[$i]} .1.3.6.1.2.1.1.5.0)
    (cat <<EOF
<Plugin snmp>
<Host "$n">
Address "${ip_addr[$i]}"
Version 1
Community "public"
$collectStr
</Host>
</Plugin>
EOF
    ) > /tmp/$(printf "%03d" "$(($i + 1))")-snmp-$n.conf
  done
}
