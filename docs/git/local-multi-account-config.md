# 配置本地多账户

## 一、配置用户名和密码
- 查看当前用户名和密码
```shell
git config user.name
git config user.email
```
- 设置全局用户名和密码
```shell
git config --global user.name "username"
git config --global user.email "email"
```

## 二、生成密钥
```shell
ssh-keygen -t ed25519 -C "your_email@example.com"
# 如何系统较老旧不支持 ed25519 ，可以使用下面的加密算法
ssh-keygen -t rsa -b 4096 -C 'xxx@email.com' -f file_name
```

![generator-sshkey](../../assets/git/local-mutil-account-config/gengrator_ssh_key_1.png)

## 三、配置到git仓库

示例：配置到 [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?platform=linux) 

## 四、编写ssh配置文件

在 `~/.ssh` 目录下创建名字为 `config` 的无后缀文件

每个账号单独配置一个Host，每个Host要取一个别名，每个 Host 必须配置 HostName 和 IdentityFile 两个属性。

常用编辑配置说明：

- Host：定义Host的名字，可以任取自己喜欢的名字，不过这个会影响 Git 相关命令。
    > 例如：Host mygithub 这样定义的话，即 git@ 后面紧跟的名字改为 mygithub。
    > 
    > 命令如下：
    > ```shell
    > git clone git@cntvc:cntvc/cntvc.git。
    > ```
    >  一般都会和HostName属性其一样的名字
    > 
- HostName：这个是真实的域名地址，要登录主机的主机名。（建议与Host一致
- IdentityFile：指定私钥文件的路径，也就是id_rsa文件的绝对路径。
- User：配置登录名，例如：GitHub的username。
- Port：端口号（如果不是默认22端口，则需要指定端口号）
- PreferredAuthentications：配置登录时用什么权限认证，可设为 publickey, password publickey, keyboard-interactive等。

配置示例
```config
HOST github.com
    Hostname ssh.github.com
    Port 443
    User test
    IdentityFile ~/.ssh/id_ed25519
    PreferredAuthentications publickey
```

## 五、测试连接状态

```shell
ssh -T git@github.com
```

成功连接后会显示
```shell
Hi cary! You've successfully authenticated, but GitHub does not provide shell access.
```

如果测试没有成功的话，使用命令 `ssh -vT git@github.com` 查看出错信息

## FAQ

- 连接 git 仓库失败，提示私钥文件过于开放

    >  ![bad-permissions](../../assets/git/local-mutil-account-config/gengrator_ssh_key_2.png)
    >  
    >  原因：即文件权限过高，只保留读取权限即可
    >  
    >  使用 chmod 命令修改权限为 400
    >  ```shell
    >  chmod 400 publickey
    >  chmod 400 private-key
    >  ```
    >  
    >  ![chmod-400](../../assets/git/local-mutil-account-config/gengrator_ssh_key_3.png)
