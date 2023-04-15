# 芒草的梦呓

一些笔记

## 部署

### 1. 克隆项目

```bash
git clone https://github.com/cntvc/notes.git
```

### 2. 初始化环境

项目预览需要安装 Python 环境来启动 server，强烈建议使用 Python 3.9+ 的版本。

创建虚拟环境：

```bash
python3 -m venv .venv
```

进入虚拟环境：
```bash
source .venv/bin/activate
```

安装依赖：

```bash
pip install -r requirements.txt
```

### 3. 预览

```bash
mkdocs serve
```

## 鸣谢

网站使用 [mkdocs](https://www.mkdocs.org/) 工具配合 [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) 主题构建。
