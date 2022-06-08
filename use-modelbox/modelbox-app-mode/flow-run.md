# 流程图运行

流程图完成后，有如下两种方式可运行图：

## modelbox-tool

[modelbox-tool](../../tools/modelbox-tool/modelbox-tool.md)是ModelBox提供的**调试**工具，可以快速检查结果是否正确，命令如下：

```shell
modelbox-tool -verbose -log-level INFO flow -run [path_to_graph]
```

- verbose：将输出日志打印到屏幕上；

- -log-level：设置日志级别，DEBUG, INFO, NOTICE, WARN, ERROR, FATAL；

- flow：快速运行一个流程，快速验证，具体可参考[flow功能](../../tools/modelbox-tool/modelbox-tool.md#flow功能)；

## modelbox-server

ModelBox Server提供了如下方式加载运行流程图：

1. 通过默认ModelBox Plugin插件自动加载
1. 通过图形化UI运行流程图
1. 通过Restful API运行流程图

使用ModelBox加载流程图，首先需要将`$HOME/modelbox-service/conf/modelbox.conf`配置文件中的`server.flow_path`改为需要调试的流程图图文件夹目录，然后执行`$HOME/modelbox-service/modelbox restart`命令重启modelbox服务生效。

此方法也可调试开发的ModelBox插件，需要在`$HOME/modelbox-service/conf/modelbox.conf`配置中的`plugin.files`添加开发的插件动态链接库路径。

更多详细modelbox-server参考[modelbox服务](./deployment/server.md#ModelBoxServer服务配置)。
