
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










在使用ufw进行流量中转时，您需要确保已经开启了IP转发，并且设置了正确的NAT规则。以下是一些基本步骤来配置ufw以进行流量中转：

开启IP转发： 首先，您需要编辑/etc/sysctl.conf文件来开启IP转发。您可以使用以下命令来添加相应的配置：
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

配置ufw以允许转发： 接下来，您需要修改/etc/default/ufw文件中的DEFAULT_FORWARD_POLICY为ACCEPT。这可以通过编辑文件来完成：
sudo nano /etc/default/ufw
然后找到DEFAULT_FORWARD_POLICY这一行，并将其改为：
DEFAULT_FORWARD_POLICY="ACCEPT"

设置NAT规则： 在/etc/ufw/before.rules文件中，您需要添加NAT规则来进行端口转发。您可以使用以下命令来编辑文件：
sudo nano /etc/ufw/before.rules
在文件的顶部，*filter之前，添加以下内容：
# nat table rules
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
# port forwarding
-A PREROUTING -p tcp --dport 本机端口号 -j DNAT --to-destination 目标地址:目标端口号
-A PREROUTING -p udp --dport 本机端口号 -j DNAT --to-destination 目标地址:目标端口号
-A POSTROUTING -p tcp -d 目标地址 --dport 目标端口号 -j SNAT --to-source 本机内网地址
-A POSTROUTING -p udp -d 目标地址 --dport 目标端口号 -j SNAT --to-source 本机内网地址
COMMIT
请将本机端口号、目标地址和目标端口号替换为您实际的配置。
重启ufw： 最后，您需要禁用并重新启用ufw来应用更改：
sudo ufw disable && sudo ufw enable
