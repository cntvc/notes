---
date: 2025-08-11
authors:
  - cntvc
---

# Debian 13 在 Gnome 桌面环境的个性化配置

<!-- more -->

本文介绍在华硕笔记本安装 Debian 和 Windows 双系统后的一些必要配置及步骤。

## 个性化配置

### 将当前用户加入 sudo 用户组

```bash
sudo usermod -aG sudo $USER
```

### 配置 apt 源为国内源

选择[UTSC 镜像源](https://mirrors.ustc.edu.cn/help/debian.html)，创建一个文件 `/etc/apt/sources.list.d/debian.sources` ，并写入以下内容

```bash
Types: deb
URIs: http://mirrors.ustc.edu.cn/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://mirrors.ustc.edu.cn/debian-security
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
echo 60 > /sys/class/power_supply/BAT0/charge_control_end_threshold
```

```bash
sudo crontab -e
# 自定义脚本路径
@reboot /path/to/script.sh
```

### 安装 Neovim 并设置为默认编辑器

```bash
sudo apt install neovim

sudo update-alternatives --install /usr/bin/editor editor /opt/nvim-linux-x86_64/bin/nvim 50
sudo apt remove vim-tiny
```

### 常用软件推荐

- gnome-tweaks
- NTQQ
- KeepassXC
- VLC

### Gnome 常用插件

| 插件名称                                                                                     | 简介                           |
| :------------------------------------------------------------------------------------------- | :----------------------------- |
| [Vitals](https://extensions.gnome.org/extension/1460/vitals/)                                | 显示电池、CPU 和内存使用情况   |
| [Applications Menu](https://extensions.gnome.org/extension/6/applications-menu/)             | 为应用程序添加基于类别的菜单   |
| [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)                     | 自动隐藏 Dock 栏               |
| [Places Status Indicator](https://extensions.gnome.org/extension/8/places-status-indicator/) | 添加菜单以快速导航系统中的位置 |
| [Auto Move Windows](https://extensions.gnome.org/extension/16/auto-move-windows/)            | 自动移动窗口                   |
| [Appindicator Support](https://extensions.gnome.org/extension/615/appindicator-support/)     | 显示应用程序托盘图标           |
| [User Themes](https://extensions.gnome.org/extension/19/user-themes/)                        | 自定义主题                     |

### 配置 Rime 输入法

```bash
sudo apt-get install ibus-rime

ibus-setup
```

### 设置常用软件别名

```bash
sudo ln -s /usr/bin/gnome-text-editor /usr/bin/gedit
```

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
