# GPG

## 使用GPG对commit签名失败
相似问题及解决方案:
[stackoverflow](https://stackoverflow.com/a/42265848), [gist](https://gist.github.com/paolocarrasco/18ca8fe6e63490ae1be23e84a7039374)

```bash
error: gpg failed to sign the data
fatal: failed to write commit object
```

- 首先对git命令进行追踪，在出错的步骤前加上命令`GIT_TRACE=1`，如下所示

```bash
GIT_TRACE=1 git commit -m "example" -S
```

- 接下来会显示出git的具体执行情况

```bash
20:52:58.902766 git.c:328               trace: built-in: git 'commit' '-vvv' '-m' 'example commit message'
20:52:58.918467 run-command.c:626       trace: run_command: 'gpg' '--status-fd=2' '-bsau' '23810377252EF4C2'
error: gpg failed to sign the data
fatal: failed to write commit object
```

- 再次执行出错的步骤，这会清晰打印出错误原因

```bash
echo "dummy" | gpg -bsau 23810377252EF4C2
```

出错原因可能有多种，在出现下面的问题时

```bash
gpg: signing failed: Inappropriate ioctl for device
gpg: [stdin]: clear-sign failed: Inappropriate ioctl for device
```

设置环境变量```export GPG_TTY=$(tty)```即可解决

- 最后，对签名进行测试

```bash
echo "test" | gpg --clearsign
```

## 设置 gpg-agent 密钥过期时间
建立文件 `$HOME/.gunpg/gpg-agent.conf`

```conf
default-cache-ttl 259200 # 单位秒
max-cache-ttl 864000
```

设置后需要重启 gpg-agent 进程