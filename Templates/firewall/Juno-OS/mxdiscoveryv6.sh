#!/bin/bash

# Criado por: Fernando Almondes
# By: Bee Solutions
# Data: 16/11/2022

# Definindo permissoes
# mkdir /var/tmp/zabbix/
# chown -R zabbix:zabbix /var/tmp/zabbix/

COMMUNITY=$1
IP=$2

echo "" > /var/tmp/zabbix/lista_ips_hex_v6.txt
echo "" > /var/tmp/zabbix/lista_index_base_v6.txt
echo "" > /var/tmp/zabbix/lista_asn_v6.txt

# Aqui descubro a lista de OIDs Esperado
lista_index=$(snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.4.1.2636.5.1.1.2.1.1.1.14 | grep -v '14.0.1' | awk -F':' '{print $2}')

snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.4.1.2636.5.1.1.2.1.1.1.11 | grep -v '14.0.1' | grep -v '11.0.1' | awk -F':' '{print $2}' | sed 's/ //g' > /var/tmp/zabbix/lista_ips_hex_v6.txt
snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.4.1.2636.5.1.1.2.1.1.1.11 | grep -v '14.0.1' | grep -v '11.0.1' | awk -F 'iso.3.6.1.4.1.2636.5.1.1.2.1.1.1.11.' '{print $2}' | awk '{print $1}' > /var/tmp/zabbix/lista_index_base_v6.txt
snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.4.1.2636.5.1.1.2.1.1.1.13 | grep -v '13.0.1' | awk -F ':' '{print $2}' | sed 's/ //g' > /var/tmp/zabbix/lista_asn_v6.txt

sed '/^$/d' -i /var/tmp/zabbix/lista_ips_hex_v6.txt
sed '/^$/d' -i /var/tmp/zabbix/lista_index_base_v6.txt
sed '/^$/d' -i /var/tmp/zabbix/lista_asn_v6.txt

lista_final=$(paste /var/tmp/zabbix/lista_index_base_v6.txt /var/tmp/zabbix/lista_ips_hex_v6.txt /var/tmp/zabbix/lista_asn_v6.txt -d ";")

echo [

last_line=$(echo "$lista_index" | wc -w)

for i in $lista_final
do

current_lines=$(($current_lines + 1))

if [[ $current_lines -ne $last_line ]]; then

echo $i | awk -F ';' '{print "{\"{#SNMPINDEX}\":\""$1"\",\"{#PEERIP}\":\""$2"\",\"{#PEERASN}\":\""$3"\"}," }'

else

echo $i | awk -F ';' '{print "{\"{#SNMPINDEX}\":\""$1"\",\"{#PEERIP}\":\""$2"\",\"{#PEERASN}\":\""$3"\"}" }'

fi

done

echo ]