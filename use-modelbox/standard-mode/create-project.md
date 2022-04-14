# 项目创建

## 启动开发模式

创建项目前需要先启动ModelBox开发模式，ModelBox开发模式提供了可视化UI编排等多种开发能力。
开发者可以通过命令行工具[modelbox-tool](../../tools/modelbox-tool/modelbox-tool.md)来启动ModelBox开发模式：

```shell
modelbox-tool develop -s

# 会打印如下ModelBox开发调试信息：
Debug ModelBox Info:
  Home:            $HOME/modelbox-service
  Config:          $HOME/modelbox-service/conf/modelbox.conf
  Log:             $HOME/modelbox-service/log
  Service command: $HOME/modelbox-service/modelbox {start|stop|restart|status}
  Manager command: $HOME/modelbox-service/modelbox-manager {start|stop|restart|status}
  Tool Command:    modelbox-tool server -conf /root/modelbox-service/conf/modelbox.conf
  UI URL:          http://0.0.0.0:1104/editor/
  Service Status:  modelbox service is running. pid xxxx
  Manager Status:  modelbox-manager service is running. pid xxxx
```

打印信息说明如下：

- Home：ModelBox开发调试管理工具目录

- Config：ModelBox服务配置文件

- Log：ModelBox调试日志目录

- Service command：ModelBox Server命令工具，可启动、停止、重启、查询ModelBox服务状态

- Manager command：modelbox-manager用来监控管理ModelBox服务

- Tool Command：ModelBox插件服务查询命令

- UI URL：可视化编排服务服务URL

- Service Status：ModelBox服务状态和pid

- Manager Status：modelbox-manager 服务状态和pid

后面也可通过`modelbox-tool develop -q`查询ModelBox开发调试信息。

## 创建项目

有两种方式创建项目工程：UI界面创建项目，命令行创建项目。

### UI界面创建项目

通过[可视化UI编排](../../plugins/editor.md#可视化编排服务)界面创建项目步骤如下：

```txt
进入UI界面 -> 点击“编排”进入任务编排页面 -> 点击“项目”，“新建项目” -> 填写“项目名称”、“项目路径”、“项目模板”
```

可在对应目录下创建ModelBox项目工程。

### 命令行创建项目

ModelBox提供了[modelbox-tool工具](../../tools/modelbox-tool/modelbox-tool.md#template功能)一键式创建工程：

```shell
modelbox-tool template -project -name [name] -template [template_name] -path [project_path]
```

- 参数说明

  -name：项目名称；

  -template：选择创建项目的模板类型，可选参数：`empty`、`mnist`、`mnist-mindspore`、`hello-world`、`car_detection`、`emotion_detection`、`resize`；
  
  -path：项目工程路径；

更多详细参数使用可通过`modelbox-tool template --help`查询。

## 项目工程目录

创建好的工程目录如下：

```tree
├─CMake：CMake目录，存放一些自定义CMake函数
├─package：CPack打包配置目录，目前支持tgz、rpm、deb三种格式
├─src：源代码目录，开发的功能单元、流程图、服务插件（可选）都存放在这个目录下
│  ├─flowunit：功能单元目录
│  ├─graph：流程图目录
│  └─service-plugin：服务插件目录
├─test：单元测试目录，使用的是Gtest框架
└─thirdparty：第三方库目录
│    └─CMake：预制的下载第三方库cmake文件
|---CMakeLists.txt  CMake编译文件
```

工程目录创建好后，开发者可在src目录下开发功能单元、流程图、服务插件（可选），基于此工程目录通过`cmake ..`、`make package`命令一键打包出tgz和rpm/deb包。
