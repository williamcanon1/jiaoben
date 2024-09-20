#!/bin/bash
apt update
apt install curl wget vim sudo bash-completion tmux fail2ban ufw -y
read -p "新建用户名" User

read -s -p "用户密码" PAss1
echo -e \ 
read -s -p "再次输入" PAss2

if [ $PAss1 == $PAss2 ];then
PAsss=$PAss1
else
echo 两个密码不一致请重新输入
exit
fi
echo -e \ 
read -p "是否更改登录端口号--是请输入1，直接回车不更改" numb

if [ $numb -eq 1 ];then
read -p "输入ssh端口号" duank
else
duank=22
fi


useradd -m -g root $User

#echo -e "$PAsss\n$PAsss" | passwd &User

echo "$User:$PAsss" | chpasswd

sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

sed -i '20a\'$User'    ALL=(ALL:ALL) NOPASSWD:  ALL' /etc/sudoers

sed -i '/Port/d' /etc/ssh/sshd_config

sed -i '/PermitRootLogin/d' /etc/ssh/sshd_config

sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config

sed -i '/KbdInteractiveAuthentication/d' /etc/ssh/sshd_config

sed -i '14a\Port '$duank'' /etc/ssh/sshd_config

sed -i '33a\PermitRootLogin no' /etc/ssh/sshd_config

sed -i '62a\PasswordAuthentication yes' /etc/ssh/sshd_config

systemctl restart sshd

cat > /etc/fail2ban/jail.local  << EOF
#DEFAULT-START
[DEFAULT]
bantime = 600
findtime = 300
maxretry = 5
banaction = ufw
action = %(action_mwl)s
#DEFAULT-END

[sshd]
ignoreip = 127.0.0.1/8
enabled = true
filter = sshd
port = $duank
maxretry = 5
findtime = 300
bantime = 600
banaction = ufw
action = %(action_mwl)s
logpath = /var/log/auth.log
EOF

systemctl restart fail2ban.service 

echo “您的新用户名为 $User 登录端口为 $duank
