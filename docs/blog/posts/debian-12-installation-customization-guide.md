---
date: 2024-11-01 
authors:
    - cntvc
---

# Debian 12 安装与个性化配置

<!-- more -->

本文介绍在华硕笔记本安装 Debian 和 Windows 双系统后的一些必要配置及步骤。

## 个性化配置

### 将当前用户加入 sudo 用户组
```bash
sudo usermod -aG sudo $USER
```

### 配置 apt 源为国内源

选择[清华源](https://mirrors.tuna.tsinghua.edu.cn/help/debian/)，编辑 `/etc/apt/sources.list` 文件，将内容替换为以下内容：

```bash
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
```

### 设置 apt 代理
```bash
echo 'Acquire::http::Proxy "http://127.0.0.1:10800/";' | sudo tee /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Proxy "http://127.0.0.1:10800/";' | sudo tee -a /etc/apt/apt.conf.d/proxy.conf
```

### Windows 双系统设置时间同步
Windows系统采用 localtime 时区，而 Debian 系统采用 UTC 时区，因此需要设置时区同步

将 Debian 设置为 localtime 时区并且同步到硬件时钟

```bash
sudo apt install ntpdate
sudo ntpdate time.windows.com
sudo hwclock --localtime --systohc
```

### 安装 NVIDIA 驱动

Debian 12 在关机时会卡在关机界面```kvm: exiting hardware virtualization```，安装完 NVIDIA 驱动即可正常关机。安装步骤详情见 [Debian wiki](https://wiki.debian.org/NvidiaGraphicsDrivers)

```bash
sudo apt install nvidia-detect -y
sudo apt install linux-headers-amd64 -y
sudo apt install nvidia-driver firmware-misc-nonfree -y
```

如果开启了 Secure Boot，需要手动注册签名密钥。Debian 使用动态内核模块系统 (DKMS) 允许在不更改整个内核的情况下升级各个内核模块。由于 DKMS 模块是在用户自己的计算机上单独编译的，因此无法使用 Debian 项目的签名密钥对 DKMS 模块进行签名。使用 DKMS 构建的模块将使用机器所有者密钥 (MOK) 进行签名，默认情况下该密钥位于 /var/lib/dkms/mok.key 与相应的公钥 /var/lib/dkms/mok.pub 。该密钥是自动生成的，但需要通过运行以下命令手动注册：

```bash
sudo mokutil --import /var/lib/dkms/mok.pub # prompts for one-time password
sudo mokutil --list-new # recheck your key will be prompted on next boot

# <rebooting machine then enters MOK manager EFI utility: enroll MOK, continue, confirm, enter password, reboot>

sudo dmesg | grep cert # verify your key is loaded
```

相关问题: https://askubuntu.com/a/1482872


### 修改 home 目录的文件夹名为英文
```bash
export LANG=en_US
xdg-user-dirs-gtk-update
```

```bash
export LANG=zh_CN.UTF-8  
xdg-user-dirs-gtk-update
```

### 自定义引导设置


```ini title="/etc/default/grub"
# 关闭 Grub 引导时间
GRUB_TIMEOUT=0

# 关闭检测和引导其他系统（如果安装了多系统）
GRUB_DISABLE_OS_PROBER=true
```

```bash
sudo update-grub
```


### 设置电池充电上限

华硕笔记本电脑修改文件 `/sys/class/power_supply/BAT0/charge_control_end_threshold` 中数字即可设置电池充电上限

将该过程保存为 sh 脚本文件并赋予可执行权限
```bash
`echo 60 > /sys/class/power_supply/BAT0/charge_control_end_threshold`
```

```bash
sudo crontab -e
# 自定义脚本路径
@reboot /path/to/script.sh
```

### 安装 Neovim 并设置为默认编辑器
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim

sudo update-alternatives --install /usr/bin/editor editor /opt/nvim-linux-x86_64/bin/nvim 50
sudo apt remove nano vim-tiny
```

### Gnome 常用插件
| 插件名称 | 简介 |
|:---|:---|
| [Vitals](https://extensions.gnome.org/extension/1460/vitals/) | 显示电池、CPU 和内存使用情况 |
| [Applications Menu](https://extensions.gnome.org/extension/6/applications-menu/) | 为应用程序添加基于类别的菜单 |
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/) | 自动隐藏 Dock 栏 |
| [Places Status Indicator](https://extensions.gnome.org/extension/8/places-status-indicator/) | 添加菜单以快速导航系统中的位置 |
| [Auto Move Windows](https://extensions.gnome.org/extension/16/auto-move-windows/) | 自动移动窗口 |
| [Appindicator Support](https://extensions.gnome.org/extension/615/appindicator-support/) | 显示应用程序托盘图标 |
| [User Themes](https://extensions.gnome.org/extension/19/user-themes/) | 自定义主题 |
| [Kimpanel](https://extensions.gnome.org/extension/261/kimpanel/) | 与 Gnome 风格一致的fcitx 输入法主题 |


### 配置 Fcitx5 输入法

https://muzing.top/posts/3fc249cf/

### 设置常用软件别名
```bash
sudo ln -s /usr/bin/gnome-text-editor /usr/local/bin/gedit
```

### 补齐依赖
```bash
# 在以 su 启动 gnome-text-editor 时出现一些错误，安装 dbus-x11 即可解决
sudo apt install dbus-x11 -y
```

## 安装问题及解决方案

### `Executing 'grub-install dummy' failed`

可能是 BIOS 存储的安全数据出现兼容性错误，尝试重置 BIOS 为出厂状态

对于华硕笔记本，按照官方文档重置安全启动密钥：[重置 BIOS 安全启动密钥](https://www.asus.com.cn/support/faq/1047551/)，再重置BIOS设置

如果以上方法无法解决，则尝试进行 CMOS 清除，见[BIOS更新不慎关机-情境3](https://www.asus.com.cn/support/faq/1040405/)：先移除电源线及电池排线，长按电源键 40 秒以上，再重新接入电源线及电池排线，开机后进入 BIOS 并进行重置 BIOS 步骤。

### 引导出现错误，无法进入系统

手动进行引导以启动系统，启动 Debian 镜像安装程序，在选择安装类型界面按 C 键进入 grub 命令行模式

```bash
grub> ls                     # 查看所有分区(硬盘和分区)
grub> ls (hd1,gpt3)/         # 比如查看第一块硬盘的第三个gpt分区（gpt3）的根目录
grub> set root=(hd1,gpt3)
grub> linux /boot/vmlinuz-6.1.0-12-amd64 root=/dev/nvme1n1p3
grub> initrd /boot/initrd.img-6.1.0-12-amd64
grub> boot # 开始引导启动
```
进入系统后执行 ```sudo update-grub``` 更新 grub 配置
