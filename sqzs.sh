#!/bin/bash

echo 安装acme
curl https://get.acme.sh | sh #安装acme
echo 安装socat
apt install socat  #安装socat
echo 创建软链
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
echo 注册
acme.sh --register-account -m my@example.com
echo 开放 防火墙
ufw allow 80
acme.sh --set-default-ca --server letsencrypt


read -p "输入申请方式   1为tcp方式    2为dns方式     " Fangshi
if [ $Fangshi -eq 1 ];then

read -p "输入域名" website
acme.sh  --issue -d $website  --standalone -k ec-256
echo 安装证书 
read  -e -p "输入安装路径" Luji
if [ -e $Luji ];then
        echo 文件存在
else
        mkdir -p $Luji
fi
acme.sh --installcert -d $website --ecc  --key-file   $Luji/server.key   --fullchain-file  $Luji/server.crt 

elif [ $Fangshi -eq 2 ];then
echo 开始已dns方式获取证书
read -p "输入key   " Key
read -p "输入邮箱   " Mail
export CF_Key="$Key"
export CF_Email=$Mail
read -p "输入域名" website

echo 开始申请 证书|
acme.sh --issue --dns dns_cf -d $website -d *.$website -k ec-256

echo 安装证书 
read  -e -p "输入安装路径" Luji
if [ -e $Luji ];then
        echo 文件存在
else
        mkdir -p $Luji
fi
acme.sh --installcert -d $website --ecc  --key-file   $Luji/server.key   --fullchain-file  $Luji/server.crt 
