# WSL2 使用window代理网络


## 一、新建文件 `proxy.sh`

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

## 二、修改 `.bashrc` 文件
```bash
# proxy in terminal
alias proxy="source ~/proxy.sh"
source ~/proxy.sh set
```