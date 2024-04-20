
相同
read -p '输入端口' DuanKou
read -p '输入目标ip' MuBiaoIP

iptables -t nat -A PREROUTING -p tcp -m tcp --dport $DuanKou -j DNAT --to-destination $MuBiaoIP:$DuanKou
iptables -t nat -A PREROUTING -p udp -m udp --dport $DuanKou -j DNAT --to-destination $MuBiaoIP:$DuanKou
iptables -t nat -A POSTROUTING -d $MuBiaoIP -p tcp -m tcp --dport $DuanKou -j SNAT --to-source $BenDiIP
iptables -t nat -A POSTROUTING -d $MuBiaoIP -p udp -m udp --dport $DuanKou -j SNAT --to-source $BenDiIP


不同
read -p '输入本地端口' BenDiIPDuanKou
read -p '输入目标ip' MuBiaoIP
read -p '输入目标端口' MuBiaoDuanKou

iptables -t nat -A PREROUTING -p tcp -m tcp --dport $DuanKou -j DNAT --to-destination $MuBiaoIP:$MuBiaoDuanKou
iptables -t nat -A PREROUTING -p udp -m udp --dport $DuanKou -j DNAT --to-destination $MuBiaoIP:$MuBiaoDuanKou
iptables -t nat -A POSTROUTING -d $MuBiaoIP -p tcp -m tcp --dport $BenDiIPDuanKou -j SNAT --to-source $BenDiIP
iptables -t nat -A POSTROUTING -d $MuBiaoIP -p udp -m udp --dport $BenDiIPDuanKou -j SNAT --to-source $BenDiIP

iptables -A FORWARD -p tcp --dport 65535 -j ACCEPT 


多口
#iptables -t nat -A PREROUTING -p tcp -m tcp --dport 10000:30000 -j DNAT --to-destination $MuBiaoIP:10000-30000
#iptables -t nat -A PREROUTING -p udp -m udp --dport 10000:30000 -j DNAT --to-destination $MuBiaoIP:10000-30000
#iptables -t nat -A POSTROUTING -d $MuBiaoIP -p tcp -m tcp --dport 10000:30000 -j SNAT --to-source 168.1.1.1
#iptables -t nat -A POSTROUTING -d $MuBiaoIP -p udp -m udp --dport 10000:30000 -j SNAT --to-source 168.1.1.1
