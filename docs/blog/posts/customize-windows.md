---
date: 2025-09-09
authors:
  - cntvc
---

# Windows 个性化设置

<!-- more -->

## 系统优化

### [移除 8.3 遗留的短文件名](https://schneegans.de/windows/no-8.3/)

最好在系统释放后未进入oobe阶段前进行清理，否则可能由于系统运行，这些文件名不可避免的积累在注册表中导致无法安全删除

```powershell
fsutil 8dot3name query C:

fsutil.exe 8dot3name set W: 1
fsutil.exe 8dot3name strip /s /f W:\
```

### 移除资源管理器导航栏的主页和图库
```powershell
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f
REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v "LaunchTo" /t REG_DWORD /d "1"
```

恢复主页和图库

```powershell
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f /ve /t REG_SZ /d "{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f /ve /t REG_SZ /d "CLSID_MSGraphHomeFolder"
REG DELETE "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v "LaunchTo"
```

## 数据迁移

### 环境变量
```powershell
reg export "HKCU\Environment" user_env.reg
```

### 组策略
需要下载微软官方的 [LGPO 工具](https://www.microsoft.com/en-us/download/details.aspx?id=55319)

```powershell
# 导出策略
LGPO.exe /b C:\GPOBackup

# 导入策略
LGPO.exe /g C:\GPOBackup
```

## Bug Fix

### [输入法编辑器在输入中文时首字母无法被第三方输入法接管](https://learn.microsoft.com/zh-cn/answers/questions/3971899/windows11-24h2-(-)?forum=windows-all&referrer=answers)

截止到系统 24H2 （内部版本 `26100.5074`）  该 BUG 仍未修复

修改注册表 `HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\Common` 条目
- `TouchKeyboardHasEverShown`  => `0`
- `InputPanelPageLastOpenTime`  => `2051193600`


```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\Common]
"ExpressiveSuggestionUIPageLastOpenTime"=hex(b):81,d5,f0,67,00,00,00,00
"InputPanelPageLastOpenTime"=hex(b):00,bb,42,7a,00,00,00,00
"TouchKeyboardHasEverShown"=dword:00000000
```
