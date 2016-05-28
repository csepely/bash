ip_addr=(172.16.17.98 172.16.17.102)
for i in ${!ip_addr[@]}; do n=$(snmpget -OQ -Ov -c public -v 1 ${ip_addr[$i]} .1.3.6.1.2.1.1.5.0);(cat <<EOF
<Plugin snmp>
<Host "$n">
Address "${ip_addr[$i]}"
Version 1
Community "public"
Collect "ubnt_radio_entry" "ubnt_radio_rssi_entries" "ubnt_wlstat_entry" "ubnt_airmax_entry"
</Host>
</Plugin>
EOF
          ) > /tmp/$(printf "%03d" "$(($i + 1))")-snmp-${n}.conf; done
