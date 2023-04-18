# git 常用命令

## 创建独立新分支

```shell
git checkout --orphan <branch_name>
```
> --orphan 选项用途如下，创建一个独立分支并切换到该分支，该分支没有历史提交记录

## 查看远程地址
```shell
git remote -v
```

## 变更本地分支远程地址
```shell
git remote set-url <repository> <remote-url>
```

## tag
```shell
git tag -a "" -m ""
git push origin v1.0.0
```

## 修改默认编辑器
```shell
git config --global core.editor "vim"
```
