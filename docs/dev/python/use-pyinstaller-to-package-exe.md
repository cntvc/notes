# 使用 Pyinstaller 打包 exe 应用程序


[pyinstaller官方文档链接](https://pyinstaller.org/en/stable/){ .md-button }

## 一、基本介绍

PyInstaller 可以将 Python 应用程序及其所有依赖项捆绑到一个包中，这样将打包的程序在其他计算机运行时无需安装 python 解释器的以及软件依赖包即可直接运行。

PyInstaller 支持 Python 3.7 及更高版本，打包为不同平台的程序时，需要到对应平台进行打包，例如制作 Windows 应用程序，在 Windows 上运行PyInstaller，制作 Linux 应用程序，需要在 Linux 上运行它。

Pyinstaller 打包模式有两种

- 打包为文件夹：
  文件夹内可以看到程序运行需要的所有依赖项以及资源文件，因此很方便调试程序，另外，更新代码时，只需要导入相同的依赖项集，就可以只发送更新的可执行文件，如果添加或升级了依赖项，那么则需要发送整个捆绑包。

- 打包为单文件；
  用户接触的只有一个可执行程序，简单明了，在运行该程序时，引导加载程序会在系统临时文件夹创建一个临时文件夹，然后将程序模块写入到该文件夹，当程序结束时，会自动删除这个临时文件夹，如果程序意外中断，则不会删除临时文件夹。

## 二、使用教程


### 1. 创建打包规范文件

使用命令 [pyi-makespec](https://pyinstaller.org/en/stable/man/pyi-makespec.html) 生成 `.spec` 格式的规范文件

```powershell
pyi-makespec [--onefile] yourprogram.py
```

默认情况下，pyi-makespec 生成的规范文件告诉 PyInstaller 创建一个包含主要可执行文件和动态库的分发目录。该选项 --onefile 表示生成单文件应用

这里只介绍比较常用的选项参数：

- -F (--onefile): 表示生成**单文件**应用
- -D (--onedir): 表示生成**文件夹**应用
- --specpath {DIR}: 存放生成的spec文件的文件夹，默认为当前目录
- n {NAME} (--name {NAME}): 分配给捆绑应用程序和规范文件的名称，默认为第一个脚本的基本名称

更多的参数在打包时输入会增加复杂度且容易出错，因此一般会在生成 `.spec` 规范文件后对相应参数进行修改，然后再进行打包


执行以下命令后，会在当前目录生成一个名为 `main.spec` 的配置文件
```powershell
pyi-makespec -F main.py
```

### 2. 对配置文件进行定制修改

以下是单文件程序的默认生成格式，其中语法为 Python 语法

```python title="main.spec"
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None # 加密密钥

# Analysis类的实例，要求传入各种脚本用于分析程序的导入和依赖。
a = Analysis(
    # 需要打包的代码文件，是一个列表
    ['main.py'], 

    pathex=[],

    # 脚本所需的二进制文件（ DLL、动态库、共享对象文件等） [tuple(src:str, dst:str)]
    # src:指定当前系统中的一个或多个文件 dst: 在运行时包含这些文件的文件夹的名称
    binaries=[],

    # 应用程序中包含的数据文件（图片等） [tuple(src:str, dst:str)]
    datas=[],

    # 指定脚本中需要隐式导入的模块，比如在__import__、imp.find_module()等语句中导入的模块
    # 这些方法导入的模块 PyInstaller 无法进行分析，需要手动指定导入
    hiddenimports=[],

    # 指定额外hook文件（可以是py文件）的查找路径，这些文件的作用是在PyInstaller运行时改变
    # 一些Python或者其他库原有的函数或者变量的执行逻辑（并不会改变这些库本身的代码），以便能顺利的打包完成
    hookspath=[],
    hooksconfig={},

    # 指定自定义的运行时hook文件路径（可以是py文件），在打好包的exe程序中，在运行这个exe程序时
    # 指定的hook文件会在所有代码和模块之前运行，包括main文件，以满足一些运行环境的特殊要求
    runtime_hooks=[],

    # 指定可以被忽略的可选的模块或包，因为某些模块只是PyInstaller根据自身的逻辑去查找的
    # 这些模块对于exe程序本身并没有用到，但是在日志中还是会提示“module not found”
    # 这种日志可以不用管，或者使用这个参数选项来指定不用导入
    excludes=[],

    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

# EXE类的实例，这个类是用来处理Analysis和PYZ的结果的，也是用来生成最后的exe可执行程序
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='scriptname',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True, # 设置是否显示命令行窗口
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,	
    icon="/img.ico" # 设置程序图标，默认spec是没有的，需要手动添加，参数为对规范文件的相对路径
)
```

接下来根据自己需要对文件进行修改，一般只需要修改 Analysis 和 EXE 两部分即可。

### 3. 打包生成目标文件

> 从规范文件构建时，只有以下命令行选项有效
> 
- --upx-dir: UPX_DIR UPX 实用程序的路径（默认：搜索执行路径）
- --distpath: 放置捆绑应用程序的位置（默认值：./dist）
- --workpath {WORKPATH}: 放置所有临时工作文件、.log、.pyz 等的位置（默认值：./build）
- --noconfirm: 替换输出目录（默认：SPECPATH\dist\SPECNAME）而不要求确认
- --ascii: 不包括 unicode 编码支持（默认：如果可用则包括）
- --clean: 在构建之前清理 PyInstaller 缓存并删除临时文件
- --log-level 构建时控制台消息中的详细信息量 （默认：INFO 级别）
>

执行打包命令
```powershell
pyinstaller --clean main.spec --noconfirm
```

[打包文件示例](https://github.com/cntvc/star-rail-tools/blob/main/build.spec){ .md-button }



## 三、FAQ

### 1. 打包文件过大

建议在虚拟环境中进行打包

```powershell
# 使用内置 venv 模块创建虚拟环境
python -m venv .venv
# 激活虚拟环境
.venv\Scripts\activate
# 安装 pyinstaller
pip install pyinstaller
# 打包
pyinstaller -F main.spec
```

### 2. 打包后提示找不到资源文件

**原因**: 打包单文件后，Windows系统运行时会对文件解压到临时目录，资源文件目录在临时文件夹，此时运行目录为exe程序所在目录，而资源访问的相对路径却是在临时文件夹下，如果代码中使用了类似 `os.getcwd()` 的代码访问资源文件，就会提示找不到文件。


**解决**: 见官方文档 [pyinstaller 运行时信息](https://pyinstaller.org/en/stable/runtime-information.html)
> 