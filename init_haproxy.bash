#!/bin/bash
set -eo pipefail

# latest :"5:19.03.8~3-0~ubuntu-bionic"
export DEBIAN_FRONTEND=noninteractive
export UCF_FORCE_CONFOLD=1
apt update
apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq -y install  haproxy
cat > /etc/haproxy/haproxy.cfg <<EOF
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        # An alternative list with additional directives can be obtained from
        #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  500000
        timeout server  500000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

listen stats
    bind *:1080
    stats refresh 30s
    stats uri /stats

frontend kube-api-server
    bind 172.21.21.200:6443
    mode tcp
    option tcplog
    use_backend kube-api-server-backend

backend kube-api-server-backend
   mode tcp
   option tcplog
   option tcp-check
   balance roundrobin
   server kube-0 172.21.21.11:6443 check
   server kube-1 172.21.21.12:6443 check
   server kube-2 172.21.21.13:6443 check
EOF

systemctl restart haproxy