#!/bin/bash

read -p "请输入分区大小 须带单位M/G     " FenQu

sudo fallocate -l $FenQu /swapfile

sudo chmod 600 /swapfile

sudo mkswap /swapfile

sudo swapon /swapfile

echo "/swapfile none swap sw 0 0" >> /etc/fstab
