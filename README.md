# 自用脚本


-------------------------------------------------------------------------------------------------------------

```
bash <(curl -s -L 'https://raw.githubusercontent.com/williamcanon1/jiaoben/main/wireguard.sh')
```

-------------------------------------------------------------------------------------------------------------

```
bash <(curl -s -L 'https://raw.githubusercontent.com/williamcanon1/jiaoben/main/trojan.sh')
```
------------------------------------------------------------------------------------------------------------

```
wget  -t1 -T2 https://raw.githubusercontent.com/williamcanon1/jiaoben/main/cloudflare-ddns.sh
```
-------------------------------------------------------------------------------------------------------------
```
bash <(curl -s -L 'https://raw.githubusercontent.com/williamcanon1/jiaoben/main/ubuntu_docker.sh')
```
## Tab 无法补全安装 bash-completion 
  在Linux的终端中输入tab键时，有时会出现命令不能补全的情况，此时有一种原因是bash错误。

   使用 ls -l /bin/sh 命令发现

   /bin/sh -> /bin/dash

   dash是一个不同于bash的Shell，它主要为了执行脚本而出现，而不是交互，它速度更快，但功能比bash要少的多。语法严格遵守POSIX标准。

   通过命令 ln -sf bash /bin/sh 可以将dash改成bash。此时问题可以解决。



   Ubuntu系统在某些情况下，apt-get 不能补全相关命令，可以通过修改/etc/bash.bashrc文件的相关行，把默认的#号去掉即可。

   if [ -f /etc/bash_completion ]; then

   /etc/bash_completion

   fi

   重新登录Shell即可。
----------------------
-------------------------------------------------------------------------------------------------------------
更改语言
sudo apt install locales
sudo dpkg-reconfigure locales
sudo apt install ttf-wqy-microhei ttf-wqy-zenhei xfonts-intl-chinese
