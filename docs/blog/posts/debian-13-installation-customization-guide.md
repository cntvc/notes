---
date: 2025-08-11
authors:
  - cntvc
---

# Debian 13 在 Gnome 桌面环境的个性化配置

<!-- more -->

本文介绍在华硕笔记本安装 Debian 和 Windows 双系统后的一些必要配置及步骤。

## 安装最小化 Gnome 桌面环境

1. 在选择软件安装步骤选择桌面环境时取消任何桌面环境，只选择系统工具

2. 进入系统后只有终端界面，此时挂载ISO文件作为apt源
```bash
sudo mount -o loop /path/debian-13-amd64-DVD-1.iso /mnt/debian-iso
```
编辑 apt 源文件添加挂载的目录条目
```bash title="/etc/apt/source.list"
deb [trusted=yes] file:/mnt/debian-iso trixie main contrib non-free non-free-firmware
```

3. 修改 apt 配置使其默认不安装推荐包和建议包
```bash title="/etc/apt/apt.conf"
APT::Install-Recommends "false";
APT::Install-Suggests "false";
```

4. 安装 Gnome
```bash
sudo apt install gnome-core
```

5. 安装必要的中文字体
```bash
sudo apt install fonts-wqy-zenhei fonts-wqy-microhei fonts-noto-cjk

# 中文文档，数据等
sudo apt install task-chinese-s
```

6. 切换中文语言环境
```bash
sudo dpkg-reconfigure locales
```
这里选择 `zh_CN.UTF-8 UTF-8`

## 个性化配置

### 将当前用户加入 sudo 用户组

```bash
sudo usermod -aG sudo $USER
```

### 配置 apt 源为国内源

选择[腾讯云镜像源](https://mirrors.tencent.com)，创建一个文件 `/etc/apt/sources.list.d/debian.sources` ，并写入以下内容

```bash
Types: deb
URIs: https://mirrors.tencent.com/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://mirrors.tencent.com/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
```

### Windows 双系统设置时间同步

Windows 系统采用 localtime 时区，而 Debian 系统采用 UTC 时区，因此需要设置时区同步

将 Debian 设置为 localtime 时区并且同步到硬件时钟

```bash
sudo timedatectl set-local-rtc 1 --adjust-system-clock
sudo hwclock -w
sudo timedatectl set-ntp true
timedatectl status
```

### 修改 home 目录的文件夹名为英文

```bash
nano ~/.config/xdg-user-dir.dirs
xdg-user-dirs-gtk-update
```

### 自定义引导设置

```ini title="/etc/default/grub"
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
# script.sh
echo 60 > /sys/class/power_supply/BAT0/charge_control_end_threshold

sudo crontab -e
# 自定义脚本路径
@reboot /path/to/script.sh
```

或者使用 systemd 管理

```bash title="/etc/systemd/system/battery-charge-limit.service"
[Unit]
Description=Set Battery Charge Limit to 60%
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo 60 | tee /sys/class/power_supply/BAT0/charge_control_end_threshold"
User=root

[Install]
WantedBy=multi-user.target
```

### 安装 Neovim

```bash
sudo apt install neovim

sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 30
sudo apt remove vim-tiny
```

### Gnome 常用插件

| 插件名称                                                                                     | 简介                           |
| :------------------------------------------------------------------------------------------- | :----------------------------- |
| [Vitals](https://extensions.gnome.org/extension/1460/vitals/)                                | 显示电池、CPU 和内存使用情况   |
| [Applications Menu](https://extensions.gnome.org/extension/6/applications-menu/)             | 为应用程序添加基于类别的菜单   |
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)                     | 自动隐藏 Dock 栏               |
| [Places Status Indicator](https://extensions.gnome.org/extension/8/places-status-indicator/) | 添加菜单以快速导航系统中的位置 |
| [Auto Move Windows](https://extensions.gnome.org/extension/16/auto-move-windows/)            | 自动移动窗口                   |
| [Appindicator Support](https://extensions.gnome.org/extension/615/appindicator-support/)     | 显示应用程序托盘图标           |

### 配置 Rime 输入法 + 雾凇拼音

```bash
sudo apt-get install ibus-rime

git clone --depth 1 https://github.com/iDvel/rime-ice
```

下载后将雾凇拼音文件移动到 `~/.config/ibus/rime` 目录，然后重新部署 `ibus restart`


## 安装问题及解决方案

### `Executing 'grub-install dummy' failed`

可能是 BIOS 存储的安全数据出现兼容性错误，尝试重置 BIOS 为出厂状态

对于华硕笔记本，按照官方文档重置安全启动密钥：[重置 BIOS 安全启动密钥](https://www.asus.com.cn/support/faq/1047551/)，再重置 BIOS 设置

如果以上方法无法解决，则尝试进行 CMOS 清除，见[BIOS 更新不慎关机-情境 3](https://www.asus.com.cn/support/faq/1040405/)：先移除电源线及电池排线，长按电源键 40 秒以上，再重新接入电源线及电池排线，开机后进入 BIOS 并进行重置 BIOS 步骤。

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

进入系统后执行 `sudo update-grub` 更新 grub 配置
