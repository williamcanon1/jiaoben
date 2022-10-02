#!/bin/bash

banben=./banben

wget -qO- -t1 -T2 "https://api.github.com/repos/tindy2013/subconverter/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g' > $banben

wget "https://github.com/tindy2013/subconverter/releases/download/$(cat $banben)/subconverter_linux64.tar.gz"

rm -rf $banben

tar zxvf subconverter*
rm subconverter_linux64.tar.gz

cat > /lib/systemd/system/sub.service << EOF
[Unit]
Description=subcon service
After=network.target syslog.target
Wants=network.target
[Service]
Type=simple
ExecStart=/root/subconverter/subconverter &

[Install]
WantedBy=multi-user.target
EOF
systemctl start sub
systemctl enable sub
ufw allow 25500/tcp
