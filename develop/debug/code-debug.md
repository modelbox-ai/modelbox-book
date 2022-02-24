# Debug

代码调试使用对应语言的调试方法即可，c++使用gdb，python使用pdb。

## GDB调试方法

C++调试使用GDB即可，在调试前，需要将对应的软件编译为DEBUG版本。

### 编译debug版本

使用CMake的编译参数，编译为DEBUG版本。

```shell
mkdir build  
cd build  
cmake -DCMAKE_BUILD_TYPE=Debug ..  
make -j32
```

### 配置调试流程图

配置构造一个简单的flow流程图，确保被调测组件能被调用。

### 启动调试

若是调试功能单元，可以使用ModelBox Tool辅助调试。

#### GDB命令

```shell
gdb modelbox-tool
set args  -verbose -log-level info flow -run [path/to/graph.conf]
b [some-func]
r
```

上述命令意思为：

* 使用gdb启动modelbox-tool
* 设置运行参数`-verbose -log-level info`表示显示日志，及设置日志级别
* `flow -run [path/to/graph.conf]`表示运行的调测流程图。
* b [some-func]对指定的函数进行断点。
* r 运行命令

注意：如果使用镜像开发，gdb提示无权限，则需要使用特权容器，具体参考[这里](../../faq/container-usage.md)的gdb调试设置

#### vscode

vscode调试，可以先下载GDB插件，再配置调试文件`.vscode/launch.json`，设置`program`和`args`两个配置项如下。

```json
"program": "modelbox-tool",
"args": [
    "-verbose",
    "-log-level",
    "info",
    "flow",
    "-run",
    "[path/to/graph.toml]"
],
```

设置完成后，使用vscode的`F5`功能键进行调试

## Python调试方法

Python调试时，则需要先设置环境变量`MODELBOX_DEBUG_PYTHON=yes`后，直接使用IDE调试，其调试方法和标准的python脚本类似。

环境变量可通过python脚本，或启动进程前的shell命令设置。

* python中设置启用

```python
import os
# 设置环境变量
os.environ['MODELBOX_DEBUG_PYTHON']="yes"
# 执行流程图
flow = modelbox.Flow()
...
```

* 环境变量中启用

```shell
export MODELBOX_DEBUG_PYTHON=yes
```

### Python功能单元调试

Python代码编写的功能单元需要从Python启动后，设置上述环境变量才能调试。但ModelBox也提供了专门用于调试Python功能单元的命令`modelbox-python-debug`。

具体操作方法为：

* IDE或调试工具设置启动程序为`modelbox-python-debug`;
* `modelbox-python-debug`启动toml文件的流程图。
  `modelbox-python-debug --flow [path/to/toml]`
* IDE或调试工具打断点，启动调试。

#### Vscode调试

vscode调试，可以配置调试文件`.vscode/launch.json`，设置`program`和`args`两个配置项如下。

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: modelbox",
            "type": "python",
            "request": "launch",
            "program": "/usr/local/bin/modelbox-python-debug",
            "args": [
                "--flow",
                "[/path/to/toml]"
            ],
            "console": "integratedTerminal"
        }
    ]
}
```

将`[/path/to/toml]`替换为实际的toml文件路径，并对需要调试的python功能单元设置断点。设置完成后，使用vscode的`F5`功能键进行调试。

**注意**： 若启用失败，则需要先安装`pydevd`包。

```shell
pip install pydevd
```
