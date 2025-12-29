# DaoCloud Mirror 加速

## 简介

本文档介绍如何通过配置 /etc/hosts 文件来加速 DaoCloud Mirror 的下载。

本文档所述的方法适用于大多数 Linux 发行版和 MacOS 系统。

### 设置 DaoCloud 镜像加速 hosts 并配置定时任务

以下脚本将设置 DaoCloud 镜像加速的 /etc/hosts 文件

``` bash
sudo wget -O /usr/local/bin/update-daocloud-mirror-hosts.sh https://files.m.daocloud.io/raw.githubusercontent.com/wzshiming/daocloud-mirror-speed-up/refs/heads/master/setup.sh
sudo chmod +x /usr/local/bin/update-daocloud-mirror-hosts.sh

sudo /usr/local/bin/update-daocloud-mirror-hosts.sh
```

由于最佳 IP 是一直变动的, 我们需要配置定时任务来定期更新 /etc/hosts 文件。

使用 `crontab` 配置定时任务，确保 hosts 文件定期更新：

``` bash
(
  sudo crontab -l 2>/dev/null;
  echo "10 0 * * * bash -c 'wget -O /usr/local/bin/update-daocloud-mirror-hosts.sh https://files.m.daocloud.io/raw.githubusercontent.com/wzshiming/daocloud-mirror-speed-up/refs/heads/master/setup.sh && chmod +x /usr/local/bin/update-daocloud-mirror-hosts.sh' >/dev/null 2>&1";
  echo "0 * * * * /usr/local/bin/update-daocloud-mirror-hosts.sh >/dev/null 2>&1"
) | sudo crontab -
```

### 取消定时任务

``` bash
sudo crontab -l | \
  grep -v '/usr/local/bin/update-daocloud-mirror-hosts.sh' | \
  sudo crontab -
sudo rm -f /usr/local/bin/update-daocloud-mirror-hosts.sh
```

### 使用 Docker 包装定时任务

您可以使用 Docker 来运行定时任务，而不是直接在主机上配置 `crontab`。

``` bash
sudo cp /etc/hosts /etc/hosts.bak
sudo chmod o+w /etc/hosts
docker run -d \
  --name daocloud-mirror-updater \
  --restart unless-stopped \
  --volume /etc/hosts:/etc/hosts:rw \
  --volume /etc/hosts.bak:/etc/hosts.bak:ro \
  m.daocloud.io/docker.io/library/alpine:latest sh -c " \
  wget -O /usr/local/bin/update-daocloud-mirror-hosts.sh https://files.m.daocloud.io/raw.githubusercontent.com/wzshiming/daocloud-mirror-speed-up/refs/heads/master/setup.sh && \
  chmod +x /usr/local/bin/update-daocloud-mirror-hosts.sh && \
  /usr/local/bin/update-daocloud-mirror-hosts.sh && \
  echo '10 0 * * * wget -O /usr/local/bin/update-daocloud-mirror-hosts.sh https://files.m.daocloud.io/raw.githubusercontent.com/wzshiming/daocloud-mirror-speed-up/refs/heads/master/setup.sh && chmod +x /usr/local/bin/update-daocloud-mirror-hosts.sh' >> /etc/crontabs/root && \
  echo '0 * * * * /usr/local/bin/update-daocloud-mirror-hosts.sh' >> /etc/crontabs/root && \
  crond -f"
```

### 停止并移除 Docker 定时任务容器

``` bash
docker stop daocloud-mirror-updater
docker rm daocloud-mirror-updater
sudo chmod o-w /etc/hosts
```

### 恢复原有 hosts 文件

``` bash
sudo mv /etc/hosts.bak /etc/hosts
```
