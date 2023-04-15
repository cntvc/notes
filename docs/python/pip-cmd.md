# pip 常用命令

- 导出当前环境下所有依赖包
```shell
pip freeze > requirements.txt
```

- 使用命令一键安装依赖包
```shell
pip freeze > requirements.txt
```

- 只生成当前环境下的依赖包
```shell
pip install pipreqs
pipreqs ./ --encoding=utf-8 --force
```

- 删除所有包
```shell
pip freeze > a.txt
pip uninstall -r a.txt -y
```
