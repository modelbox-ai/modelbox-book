# 服务安装配置

ModelBox Server提供了如下方式加载运行流程图：

1. 通过默认ModelBox Plugin插件自动加载
1. 通过图形化UI运行流程图
1. 通过Restful API运行流程图

## ModelBox Plugin插件

ModelBox Plugin插件用于对外提供服务，管理并运行流程图。此插件内置在ModelBox Server中。

默认情况下，可以直接使用此插件执行相关的流程图功能。例如，新建任务后，将使用插件运行流程图，并将结果对外输出。

* ModelBox Plugin功能说明：

![plugin-feature alt rect_w_1280](../assets/images/figure/server/plugin-feature.png)

ModelBox Plugin主要提供两个功能。

1. 添加配置文件管理流程图。
1. 调用REST API执行流程图。

### ModelBox Plugin插件配置

ModelBox Plugin插件配置文件和ModelBox Server主配置文件相同，即为`/usr/local/etc/modelbox/modelbox.conf`, ModelBox Plugin插件的配置项目如下：

| 配置项目         | 配置说明                                                                       |
| ---------------- | ------------------------------------------------------------------------------ |
| server.ip        | ModelBox Plugin绑定的管理IP地址，默认为127.0.0.1                               |
| server.port      | ModelBox Plugin绑定的管理端口，默认为1104                                      |
| server.flow_path | ModelBox Plugin加载flow配置文件的扫描路径。默认为/usr/local/etc/modelbox/graph |

为确保ModelBox Plugin插件生效，请确保插件在`/usr/local/etc/modelbox/modelbox.conf`配置文件的`plugin.files`配置项中配置此插件，并在配置完成后，重启ModelBox服务。

### 添加配置文件管理流程图

ModelBox Plugin支持通过添加流程图配置文件的形式自动执行流程图，默认情况下的流程图配置文件路径为`/usr/local/etc/modelbox/graph`, 配置文件的存放目录为：

```shell
/usr/local/etc/modelbox/graph
                        |-some-flow1.toml
                        |-some-flow2.toml
                        .
                        .
                        .
```

配置文件复制到图存储目录后，可执行ModelBox Server服务重启命令`systemctl restart modelbox`生效.

注意：

  1. ModelBox服务加载该目录下的所有文件作为flow作业，如果加载失败将跳过该flow，文件名将作为flow的作业名
  1. 文件名不要包含特殊符号，并且后缀名为`.toml`。
  1. 如果修改该配置项，需要保证指定的目录存在并具有读权限，否则将加载失败。
  1. 路径可通过`server.flow_path`参数修改。

## 图形化运行流程图

请参考[可视化编排服务](../../../plugins/editor/editor.md)。
