#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

DOMAINS="image-mirror.r2.daocloud.vip ollama-mirror.r2.daocloud.vip files-mirror.r2.daocloud.vip"

list_ips() {
    wget -qO- https://files.m.daocloud.io/gist.github.com/wzshiming/188e54d0b879724d387227d735a84470/raw/e79d307a9b7df2d38edf442b170c03095d49a9ef/cn-list.txt
}

backup_hosts() {
    if [ ! -f /etc/hosts.bak ]; then
        echo "Creating backup of /etc/hosts to /etc/hosts.bak"
        echo "创建 /etc/hosts 到 /etc/hosts.bak 的备份"
        cp /etc/hosts /etc/hosts.bak
    fi
}

generate_hosts() {
    cat /etc/hosts.bak
    echo
    echo "# Begin DaoCloud Mirror Speed-up Entries"
    for ip in $IPs; do
        echo "$ip $DOMAINS"
    done
    echo "# End DaoCloud Mirror Speed-up Entries"
    echo
}

update_hosts() {
    echo "Updating /etc/hosts"
    echo "正在更新 /etc/hosts"
    generate_hosts >/etc/hosts
}

cat_hosts() {
    echo "Update completed successfully."
    echo "更新完成。"

    cat /etc/hosts
}

IPs="$(list_ips)"

if [ -z "$IPs" ]; then
    echo "No IPs found. Exiting."
    echo "没有找到 IP，正在退出。"
    exit 1
fi

backup_hosts

update_hosts

cat_hosts
