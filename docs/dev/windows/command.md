## 计算文件的哈希值

```cmd
certutil -hashfile {filepath} {algorithm: SHA256 MD5 SHA1}
```
或者使用 powshell 命令:

```powershell
Get-FileHash {filepath} -Algorithm [SHA256|MD5|SHA1|...]
```
