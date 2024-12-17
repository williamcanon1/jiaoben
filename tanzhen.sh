#!/bin/sh
mkdir tanzhen && cd tanzhen

read -p "输入key" Kkkey 

cat > docker-compose.yaml << EOF
services:
  beszel-agent:
    image: "henrygd/beszel-agent"
    container_name: "beszel-agent"
    restart: unless-stopped
    network_mode: host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # monitor other disks / partitions by mounting a folder in /extra-filesystems
      # - /mnt/disk/.beszel:/extra-filesystems/sda1:ro
    environment:
      PORT: 45876
      KEY: "Kkkey"
EOF

sudo apt update &&sudo apt install docker-compose.yaml -y

sudo docker-compose up -d 
