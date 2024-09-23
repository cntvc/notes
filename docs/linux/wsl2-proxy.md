# WSL2 使用 Windows 代理网络

## Windows 11 22H2 及以上版本

可使用最新 WSL2 内核，并在全局配置文件 `.wslconfig` 中加入以下配置即可实现代理网络

```txt
networkingMode=mirrored
dnsTunneling=true
autoProxy=true
```

> 如果更新内核后依旧无法使用代理，尝试在设置中重置系统组件应用 `适用于 Linux 的 Windows 子系统`

## Windows 10 系统

### 方法一: 配置 HTTP(S)/SOCKS5 代理

- 开启代理工具的允许局域网访问适用于 linux
- 在 WSL2 中配置 HTTP(S)/SOCKS5 代理

#### 1. 新建文件 `proxy.sh`

```bash
hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
wslip=$(hostname -I | awk '{print $1}')
port=1080
PROXY_SOCKS="http://${hostip}:${port}"

function display() {
    echo "Host ip: ${hostip}"
    echo "WSL client ip: ${wslip}"
    echo "current PROXY: ${PROXY_SOCKS}"
}

function set_proxy() {
    export http_proxy="${PROXY_SOCKS}"
    export https_proxy="${PROXY_SOCKS}"
    echo "env http/https proxy set."
}

function unset_proxy() {
    unset http_proxy
    unset https_proxy
    echo "env proxy unset."
}

function test_proxy() {
    curl -vv www.google.com
}

if [ "$1" = "show" ]; then
    display
elif [ "$1" = "set" ]; then
    set_proxy
elif [ "$1" = "unset" ]; then
    unset_proxy
elif [ "$1" = "test" ]; then
    test_proxy
else
    echo "incorrect arguments."
fi
```

#### 2. 修改 `.bashrc` 文件
```bash
# proxy in terminal
alias proxy="source ~/proxy.sh"
source ~/proxy.sh set
```

### 方法二: 使用 TUN 模式代理
- 开启代理工具的 TUN 模式
- 配置 UWP 应用的联网限制，放行 WSL2
