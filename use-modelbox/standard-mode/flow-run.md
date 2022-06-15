# 流程图运行

流程图完成后，有如下两种方式可运行图：

## 通过modelbox-tool运行

[modelbox-tool](../../tools/modelbox-tool/modelbox-tool.md)是ModelBox提供的**调试**工具，可以快速检查结果是否正确，命令如下：

```shell
modelbox-tool -verbose -log-level INFO flow -run [path_to_graph]
```

- verbose：将输出日志打印到屏幕上；

- -log-level：设置日志级别，DEBUG, INFO, NOTICE, WARN, ERROR, FATAL；

- flow：快速运行一个流程，快速验证，具体可参考[flow功能](../../tools/modelbox-tool/modelbox-tool.md#flow功能)；

## 通过modelbox进程运行

使用ModelBox加载流程图，不仅可以运行流程图，还可以加载自定义插件

需要修改`$HOME/modelbox-service/conf/modelbox.conf`配置文件以下几个部分：

- 修改流程图路径`server.flow_path`：

  ```json
  [server]
  ip = "127.0.0.1"
  port = "1104"
  flow_path = "/usr/local/etc/modelbox/graph/"  # 修改为自定义流程图目录
  ```

- 添加开发的插件路径`plugin.files`：
  
  ```json
  [plugin]
  files = [
      "/usr/local/lib/modelbox-plugin.so",
      "/usr/local/lib/modelbox-plugin-editor.so"  # 添加开发插件路径
  ]
  ```

- 设置日志配置：

  ```json
  [log]
  level = "INFO"                               # 设置日志级别
  num = 32                                     # 设置日志归档文件最大个数
  path = "/var/log/modelbox/modelbox.log"      # 设置日志路径
  ```

执行`$HOME/modelbox-service/modelbox restart`命令重启ModelBox服务生效。

更多详细modelbox运行参考[modelbox运行](./deployment/server.md#ModelBoxServer服务配置)。
