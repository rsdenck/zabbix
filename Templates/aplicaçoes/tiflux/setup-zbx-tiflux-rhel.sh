#!/bin/bash

VERIFICA_USER_ZABBIX=$(grep '/home/zabbix:/bin/bash' /etc/passwd)
RESP=$?

if [ "$RESP" -eq 1 ]; then
	echo 'Diretorio home do zabbix nao esta padronizado para instalacao e/ou nao foi definido o bash para o usuario do zabbix.'
	exit 1
fi

if [ -d /home/zabbix ]; then
	echo 'Diretorio do usuario Zabbix ok. Pronto para instalacao...';
else
	echo 'Diretorio zabbix nao existe. Criando e ajustando as permissoes.';
	mkdir /home/zabbix && chown -R zabbix:zabbix /home/zabbix && chmod -R 700 /home/zabbix
fi

dnf install -y python3-virtualenv python3-pip unzip && \
su - zabbix -c 'cd /home/zabbix' && \
su - zabbix -c 'wget https://tiflux.com/zabbix-tiflux.zip' && \
su - zabbix -c 'unzip zabbix-tiflux.zip' && \
su - zabbix -c 'python3 -m venv --system-site-packages /home/zabbix/tiflux/venv' && \
su - zabbix -c 'source /home/zabbix/tiflux/venv/bin/activate && pip3 install wheel && pip3 install -r /home/zabbix/tiflux/scripts/requirements.txt --no-cache-dir' && \
rm -f /home/zabbix/zabbix-tiflux.zip
echo 'Setup do Zabbix + TiFlux finalizado.'
