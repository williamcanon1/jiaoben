curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
cat > /etc/docker/daemon.json << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    },
    "ipv6": true,
    "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
    "experimental":true,
    "ip6tables":true
}
EOF
systemctl restart docker
