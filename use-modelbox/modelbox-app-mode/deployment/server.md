# Server服务

通常情况下，ModelBox可以看作是一个应用服务。当需要运行ModelBox时，需要启动ModelBox Server服务。ModelBox Server是最基本也是最重要的服务,ModelBox Server服务提供流程图的加载、可视化编排UI服务、流程图Restful API等能力。用户只需将[flow流程图](../../../basic-conception/basic-conception.md)配置文件放到指定的目录下，即可实现flow作为服务的功能。

## Server服务使用流程

![server-usage alt rect_w_600](../assets/images/figure/server/server-usage.png)

在ModelBox镜像中，Server服务是预编译好的可执行文件，在使用时，按照正常的服务流程使用，其流程为：

1. 安装服务。
1. 启动服务。
1. 修改服务配置文件。
1. 重启服务使配置生效。
1. 添加流程图。
1. 管理扩展插件。

## 启动管理服务

ModelBox Server服务使用标准的systemd unit管理，启动管理服务，使用systemd命令管理。

当运行环境支持Systemd时，可通过如下命令对ModelBox服务进行操作：

* `sudo systemctl status modelbox.service`：查看ModelBox服务的状态。
* `sudo systemctl stop modelbox.service`：停止ModelBox服务。
* `sudo systemctl start modelbox.service`：启动ModelBox服务。
* `sudo systemctl restart modelbox.service`：重启ModelBox服务。

如无systemd管理机制时，可以使用SysvInit命令管理ModelBox服务，命令如下：

```shell
sudo /etc/init.d/modelbox [start|status|stop]
```

此方式相比systemd，缺失了进程的监控，所以建议优先使用systemd启动ModelBox服务。

如需要监控机制，可以使用ModelBox Manager来管理，可以从ModelBox Manager来启动Modelbox服务，命令如下

```shell
sudo /etc/init.d/modelbox-manager [start|status|stop]
```

## ModelBox Server服务配置

ModelBox Serverf服务配置文件中包含主服务配置、插件、服务启动参数、编排服务配置和访问控制列表。
一个典型modelbox.conf配置文件如下图所示：

```shell
[server]
ip = "127.0.0.1"
port = "1104"
flow_path = "/usr/local/etc/modelbox/graph/"

[acl]
allow = [
    "127.0.0.1/8"
]

[control]
enable = true
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

ModelBox服务相关配置文件和配置功能说明如下：

| 配置类别         | 配置文件                              | 说明                                                                                                            |
| ---------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 主服务配置       | /usr/local/etc/modelbox/modelbox.conf | 包含基本的配置信息，如插件路径，日志级别。                                                                      |
| 插件配置         | /usr/local/etc/modelbox/modelbox.conf | 和具体插件相关。                                                                                                |
| 编排服务配置     | /usr/local/etc/modelbox/modelbox.conf | 包括编排服务的配置信息，详情可见[运行服务](../../../plugins/editor/editor.md)中的[可视化编排服务](../../../plugins/editor/editor.md#配置启用Editor)         |
| 访问控制列表     | /usr/local/etc/modelbox/modelbox.conf | 可访问ModelBox后端服务的白名单列表，详情可见[运行服务](../../../plugins/editor/editor.md)中的[访问控制列表](../../../plugins/editor/editor.md#访问控制列表) |
| 服务启动参数配置 | /usr/local/etc/modelbox/modelbox-opts | 支持配置ModelBox Server服务的启动参数。                                                                         |

### 主服务配置项

主服务配置主要配置插件列表，日志级别信息，具体配置项如下：

| 配置项          | 配置功能                                                                                                                   |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `plugin.files`  | ModelBox Server插件列表，顺序加载。                                                                                        |
| `log.level`     | ModelBox服务日志级别，默认为INFO，支持DEBUG, INFO, NOTICE, WARN, ERROR, FATAL, OFF，如果指定OFF，将关闭日志打印。          |
| `log.num`       | ModelBox服务日志归档文件个数最大值，默认为32，当归档日志超过该阈值时，最旧归档日志文件将删除。                             |
| `log.path`      | ModelBox服务日志文件路径，默认为`/var/log/modelbox/modelbox.log`。如果修改该配置项，需要保证日志目录存在且具有可读写权限。 |
| `include.files` | ModelBox服务配置的子配置路径，当子配置存在字段和主配置相同时，取子配置的值。                                               |

* 插件服务配置

除上述配置外，其他配置均为插件配置。ModelBox服务支持灵活的[ModelBox服务插件](../service-plugin/service-plugin.md)加载，ModelBox启动后，会按照plugin.files配置的插件，顺序加载插件，各插件的配置参考各自插件配置参数。当前ModelBox的可视化编排及流程图的restful api及通过服务插件实现, 每个插件有各自配置字段：

`modelbox-plugin`插件的配置，可参考[服务安装配置](./run-flow.md)。

`modelbox-plugin-editor`插件的配置，可参考[可视化编排服务](../../../plugins/editor/editor.md)。

### ModelBox服务启动参数配置

ModelBox Server服务启动参数配置项目如下：

| 配置项          | 配置功能                                                                                                                   |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `MODELBOX_OPTS` | ModelBox服务启动时会加载该变量的内容作为启动参数。如果用户需要重新指定其他的ModelBox服务运行配置时，可修改该变量的值实现。 |

## ModelBox Server预置功能列表

ModelBox Server可以通过自定义插件的形式扩展其基本功能，默认情况下，ModelBox Server集成了任务管理REST API服务，以及流程图的执行能力, ModelBox集成的插件列表。

| 插件                   | 功能               | 说明                                                         | 使用指导            |
| ---------------------- | ------------------ | ------------------------------------------------------------ | ------------------- |
| modelbox-plugin        | 默认流程图执行插件 | 默认的流程图执行插件，支持REST API管理流程图，和其执行结果。 | [指导](./run-flow.md) |
| modelbox-plugin-editor | 可视化编排UI插件   | 提供可视化的流程图编排UI界面。                               | [指导](../../../plugins/editor/editor.md)   |

## ModelBox Server文件目录

ModelBox Server安装完成后，对应的安装目录如下

| 文件路径                              | 说明                             |
| ------------------------------------- | -------------------------------- |
| /usr/local/bin/modelbox               | ModelBox独立服务器主进程。       |
| /usr/local/etc/modelbox               | ModelBox配置目录。               |
| /usr/local/etc/modelbox/modelbox.conf | ModelBox主程序配置文件。         |
| /usr/local/etc/modelbox/modelbox-opts | ModelBox主程序启动参数配置文件。 |
| /usr/local/etc/modelbox/graph         | ModelBox执行程序图存储目录。     |
| /lib/systemd/modelbox.systemd         | ModelBox服务启动systemd unit。   |
| /usr/local/lib/libmodelbox-*.so       | libmodelbox，以及相关插件目录。  |

## ModelBox Server运行日志

ModelBox Server运行时的日志会记录到modelbox.conf配置文件`log.path`配置指定的文件中。默认路径为[`/var/log/modelbox/modelbox.log`]
