# 打包安装

ModelBox工程采用CMake内置的CPack工具打包，将功能单元、流程图、插件（可选）等打包成rpm/deb/tar包，可一键安装，方便生产环境的部署和使用。

## 打包

打包内容包括下面几个部分：

| 内容             | 是否必选 |
| ---------------- | -------  |
| 流程图           | 是       |
| 功能单元         | 是       |
| 插件             | 否       |

打包步骤：

1. 在项目工程中新建build目录；
1. 在build目录中通过`cmake ..`、`make package`打包成rpm/deb/tar包。

下面介绍不同组件的打包内容：

* 流程图
  
  将开发好的流程图配置文件打包。

* 功能单元

  将业务开发好的功能单元打包，不同类型功能单元需要打包的内容不同。

  C++功能单元打包的是编译好的动态链接库；

  Python功能单元打包的是配置文件与Python源码；

  推理功能单元打包的是配置文件与模型文件；

* 插件

  若业务开发了自定义插件，则可将插件编译成动态链接库进行打包。

## ModelBox配置

启动ModelBox需要ModelBox配置文件，包含主服务配置、服务启动参数、插件参数等配置；

一个典型modelbox.conf配置文件如下图所示，一般只需修改`server.flow_path`路径即可：

```shell
[server]
ip = "127.0.0.1"
port = "1104"
flow_path = "/usr/local/etc/modelbox/graph/"   # 流程图目录

# [acl]
# allow = [
#     "127.0.0.1/8"
# ]

[control]
enable = false
listen = "/var/run/modelbox/modelbox.sock"

[plugin]
files = [
    "/usr/local/lib/modelbox-plugin.so",
    "/usr/local/lib/modelbox-plugin-editor.so"
]

[editor]
enable = false
root = "/usr/local/share/modelbox/www"
solution_graphs = "/usr/local/share/modelbox/solution/graphs"

[log]
level = "INFO"
num = 32
path = "/var/log/modelbox/modelbox.log"

[include]
files = [
    "/usr/local/etc/modelbox/conf.d/*.conf",
]
```

参数分为两部分：主服务配置项、内置插件配置项，下面详细介绍各配置。

* **主服务配置项**

主服务配置主要配置插件列表，日志级别信息，具体配置项如下：

| 配置项          | 配置功能                                                                                                                   |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `plugin.files`  | ModelBox Server插件列表，顺序加载。                                                                                        |
| `log.level`     | ModelBox服务日志级别，默认为INFO，支持DEBUG, INFO, NOTICE, WARN, ERROR, FATAL, OFF，如果指定OFF，将关闭日志打印。           |
| `log.num`       | ModelBox服务日志归档文件个数最大值，默认为32，当归档日志超过该阈值时，最旧归档日志文件将删除。                               |
| `log.path`      | ModelBox服务日志文件路径，默认为`/var/log/modelbox/modelbox.log`。如果修改该配置项，需要保证日志目录存在且具有可读写权限。   |
| `include.files` | ModelBox服务配置的子配置路径，当子配置存在字段和主配置相同时，取子配置的值。                                                 |
| `control.enable` | ModelBox服务调试开关，当开启时可调试。                                                                                     |
| `control.listen` | ModelBox服务调试sock路径。                                                                                                |

* **内置插件服务配置**

除上述配置外，其他配置均为插件配置。ModelBox服务支持灵活的[ModelBox服务插件](../service-plugin/service-plugin.md)加载，ModelBox启动后，会按照plugin.files配置的插件，顺序加载插件，各插件的配置参考各自插件配置参数。当前ModelBox的可视化编排及流程图的restful api及通过服务插件实现, 每个插件有各自配置字段：

`modelbox-plugin`插件的配置，可参考[服务安装配置](../../../plugins/modelbox-plugin.md)。

`modelbox-plugin-editor`插件的配置，可参考[可视化编排服务](../../../plugins/editor.md)。

## 安装

安装步骤：

1. 选择对应的[运行镜像](../../../environment/container-usage.md#支持容器列表);
1. 在运行镜像中rpm/deb可通过对应命令直接安装，tar包在根目录解压即可。默认安装目录为`/opt/modelbox/application/$project_name/`目录，这个目录下包括流程图（graph）、功能单元（flowunit）、插件。
1. ModelBox配置文件建议安装在`/usr/local/etc/modelbox/modelbox.conf`路径下。
