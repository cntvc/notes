---
date: 2025-10-06
authors:
  - cntvc
---

# 在腾讯云服务器部署 Vaultwarden 服务

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) 是 Rust 编写的 [Bitwarden](https://bitwarden.com/) 服务端第三方实现，兼容 Bitwarden 官方客户端。相比于 Bitwarden 官方服务器，Vaultwarden 部署占用资源少，维护较简单，且可以免费使用 Bitwarden 的大部分高级功能，对于家庭用户来说已足以完全替代官方。

<!-- more -->

## 前期准备

### 1. 云服务器购买与配置
   
   本文使用的是腾讯云轻量云服务器，操作系统选择 Debian13。Vaultwarden 服务对硬件要求较低，1核CPU、512MB 内存的配置即可满足中小规模使用

### 2. 域名购买和解析
   
   购买一个域名并在域名服务商处将域名解析到云服务器 IP

### 3. 国内访问与备案要求
   - 中国大陆境内云服务器提供互联网信息服务时必须备案，未备案时通过域名访问服务会被阻断，具体表现是：通过 http 访问会被重定向到一个备案页面， 通过 https 访问时会被注入一个 TCP reset 包
   - 如果主要在国内使用，并希望通过公网直连，建议域名和云服务器均在国内云服务商处购买并完成备案，这样在国内访问服务的延迟低且稳定性高
   - 如果由于某些原因不希望备案，可以通过隧道+反代的方式绕过限制，本文采用了 Cloudflare Tunnel + 反向代理方式绕过限制，实现 HTTPS 的安全访问


## 环境配置

官方从 **1.17.0** 版本开始提供了单一的 Docker 镜像，使部署与后续维护更加简洁高效。本文采用 Docker Compose 方式部署 Vaultwarden 服务

### 1. 安装 docker
  
  由于国内云服务器访问外网速度较慢，建议在安装 Docker 前**配置镜像加速源**，以避免镜像拉取超时或失败

  请参考腾讯云官方文档：[安装 Docker 并配置镜像加速源](https://cloud.tencent.com/document/product/1207/45596)

### 2. 创建独立用户用于运行 Vaultwarden 服务
  为增强安全性，建议不要使用 root 用户直接运行容器服务

```bash
# 宿主机创建独立用户
sudo useradd -r -s /usr/sbin/nologin vaultwarden
# 查看用户的 UID 与 GID
id -u vaultwarden
id -g vaultwarden

# 加入 docker 组
sudo usermod -aG docker vaultwarden
```

**说明：**

- -r 参数表示创建系统用户（无 home 目录），更适合服务进程使用
- -s /usr/sbin/nologin 禁止该用户直接登录系统，提升安全性
- 将用户加入 docker 组后，可在不使用 root 权限的前提下运行容器

## 部署 Vaultwarden 服务

Vaultwarden 服务需要启用 **HTTPS**，因为 Bitwarden 使用了大多数浏览器仅在 HTTPS 环境中提供的[网络加密 API](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto) 

通常将 vaultwarden 放在处理 HTTPS 连接的反向代理（例如 Caddy，Nginx 等）后面来实现 HTTPS 支持


### 使用 Caddy 反向代理部署 Vaultwarden

启用 HTTPS 需要配置 **SSL/TLS 证书**，个人用户通常使用 [Let's Encrypt](https://letsencrypt.org/) 签发的免费 SSL 证书

Let’s Encrypt 支持通过 HTTP 和 DNS 挑战两种方式验证域名并签发证书。
尽管可以借助 ACME 客户端手动获取证书，但推荐使用 [Caddy](https://caddyserver.com/)，它内置了使用 ACME 协议获取证书的支持，无需额外工具即可自动申请、续期证书，同时配置语法清晰、易于维护，非常适合此场景

#### 方案一：使用 HTTP 挑战方式自动签发证书

**HTTP 挑战原理**：Let’s Encrypt 通过访问服务器的特定 HTTP 路径来验证域名所有权，因此必须保证服务器能从公网访问 80 端口

**前置步骤**

- 确保云服务商服务器防火墙已放行 80/443 端口
- 确保域名的 A 记录已正确解析至服务器公网 IP

首先创建项目目录并切换到该目录下，创建 `vw-data`、`caddy` 等目录，并确保这些目录的所有权归属 `vaultwarden` 用户。然后创建 `compose.yaml` 文件，并**替换环境变量 DOMAIN 和 EMAIL 以及 user 的值**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    user: "2000:2000"
    environment:
      DOMAIN: "https://vaultwarden.example.com"
      SIGNUPS_ALLOWED: "false"
    volumes:
      - ./vw-data:/data

  caddy:
    image: caddy-cloudflare
    container_name: caddy
    restart: always
    user: "2000:2000"
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy/config:/config
      - ./caddy/data:/data
    environment:
      DOMAIN: "https://vaultwarden.example.com"
      EMAIL: "admin@example.com"
      LOG_FILE: "/data/access.log"
```

然后创建 `Caddyfile` 文件（默认配置即可使用）

```txt
{$DOMAIN} {
  log {
    level INFO
    output file {$LOG_FILE} {
      roll_size 10MB
      roll_keep 10
    }
  }

  # Use the ACME HTTP-01 challenge to get a cert for the configured domain.
  tls {$EMAIL}

  # This setting may have compatibility issues with some browsers
  # (e.g., attachment downloading on Firefox). Try disabling this
  # if you encounter issues.
  encode zstd gzip

  # Proxy everything Rocket
  reverse_proxy vaultwarden:80 {
       # Send the true remote IP to Rocket, so that vaultwarden can put this in the
       # log, so that fail2ban can ban the correct IP.
       header_up X-Real-IP {remote_host}
  }
}
```

最后启动容器并验证服务：
```bash
docker compose up -d
curl -Ikv https://vaultwarden.example.com
```


#### 方案二：使用 DNS 挑战方式自动签发证书
DNS 挑战原理：Let’s Encrypt 通过验证域名下的 TXT 记录来确认所有权，因此适用于未开放 80 端口或仅内网可访问的服务器

本文使用 Cloudflare DNS 插件完成自动验证

**前置步骤**

- 登录 Cloudflare 控制台，创建 API Token，权限需要 **区域:读取, DNS:编辑**
- 确保域名的 A 记录已正确解析至服务器公网 IP
- 构建带有 Cloudflare DNS 插件 的 Caddy 镜像

首先创建 Dockerfile
```Dockerfile
FROM caddy:builder AS builder
RUN xcaddy build --with github.com/caddy-dns/cloudflare
FROM caddy:2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

然后执行命令构建镜像 `docker build -t caddy-cloudflare -f Dockerfile`，构建完成后本地会新增一个名为 `caddy-cloudflare` 的镜像

创建 `compose.yaml` 文件，并**替换环境变量 DOMAIN,EMAIL,user 以及 CF_API_TOKEN 变量的值**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    user: "2000:2000"
    environment:
      DOMAIN: "https://vaultwarden.example.com"
      SIGNUPS_ALLOWED: "false"
    volumes:
      - ./vw-data:/data

  caddy:
    image: caddy-cloudflare
    container_name: caddy
    restart: always
    user: "2000:2000"
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy/config:/config
      - ./caddy/data:/data
    environment:
      DOMAIN: "https://vaultwarden.example.com"
      CF_API_TOKEN: "your-cloudflare-api-token"
      EMAIL: "admin@example.com"
      LOG_FILE: "/data/access.log"
```

创建 `Caddyfile` 文件
```txt
{$DOMAIN} {
  log {
    level INFO
    output file {$LOG_FILE} {
      roll_size 10MB
      roll_keep 10
    }
  }

  tls {
	dns cloudflare {$CF_API_TOKEN}
  }

  # This setting may have compatibility issues with some browsers
  # (e.g., attachment downloading on Firefox). Try disabling this
  # if you encounter issues.
  encode zstd gzip

  reverse_proxy vaultwarden:80 {
       # Send the true remote IP to Rocket, so that vaultwarden can put this in the
       # log, so that fail2ban can ban the correct IP.
       header_up X-Real-IP {remote_host}
  }
}
```

最后启动容器并验证服务：
```bash
docker compose up -d
curl -Ikv https://vaultwarden.example.com
```


#### 方案三：使用 [Cloudflare 源证书部署](https://developers.cloudflare.com/ssl/origin-configuration/)

如果域名托管在 Cloudflare，可开启代理模式，并在服务器上部署 Cloudflare 签发的源证书，实现端到端加密

登录 Cloudflare 仪表板，选择 SSL/TLS -> 源服务器，然后创建源证书

将证书部署至服务器指定目录后，在 `Caddyfile` 中配置证书路径，例如：

```txt
tls /path/to/origin.crt /path/to/origin.key
```

#### 证书校验

```bash
openssl s_client -showcerts -connect vaultwarden.example.com:443 -servername vaultwarden.example.com
```
输出的开头应该看起来像这样（使用 Let's Encrypt 证书时）：
```txt
CONNECTED(00000003)
depth=2 O = Digital Signature Trust Co., CN = DST Root CA X3
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = R3
verify return:1
depth=0 CN = vaultwarden.example.com
verify return:1
```

### 使用 [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) 部署

Cloudflare Tunnel 通过在服务器与 Cloudflare 边缘节点之间建立一条加密隧道，使外部用户能够安全访问内部服务

在这种方式下，Cloudflare 负责对外提供 HTTPS 服务并签发 TLS 证书，服务器不需要自行管理证书

首先单独部署无反向代理的 Vaultwarden 服务

`compose.yaml` 文件配置如下
```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      SIGNUPS_ALLOWED: "true" # Deactivate this with "false" after you have created your account so that no strangers can register
    volumes:
      - ./vw-data:/data # the path before the : can be changed
    ports:
      - 11001:80 # you can replace the 11001 with your preferred port
```

然后登录 Cloudflare 的 Zero Trust 仪表板，选择 网络 -> Tunnels，根据向导创建隧道并安装连接器
**注意配置域时 URL 端口与 docker 容器映射的端口必须一致**


