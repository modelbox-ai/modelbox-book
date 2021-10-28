# 运行编排服务

ModelBox提供了在线可视化编排的工具——Editor，在开发时，可使用此工具，提升开发效率。

## 编排服务是什么

编排服务是用来在Editor可视化界面上，编排[流程图](./develop/flow/flow.md)并自动生成相对应的[图](./framework-conception/graph.md)代码的快速开发工具。

## 编排服务开发使用流程

![editor-feature alt rect_w_500](../assets/images/figure/server/editor-feature.png)

1. 安装ModelBox server服务。
1. 配置ModelBox Server。
1. 配置启用编排服务。
1. 浏览器访问Editor界面。
1. 业务进行编排操作。
1. 下发编排任务。

编排服务集成在ModelBox Server中，默认情况下，编排服务未启用。可以参考下方《编排服务配置》章节来启用编排服务并加载Editor界面。

## 编排服务配置

ModelBox Server安装完成后，编排服务会通过插件的形式由ModelBox Server加载，并在网页浏览器上提供在线可视化编排服务。

对应插件路径为`"/usr/local/lib/modelbox-plugin-editor.so"`(#由于不同操作系统目录结构存在差异，此路径也可能为 `"/usr/local/lib64/modelbox-plugin-editor.so"`，下文涉及系统lib库路径的地方均存在系统路径差异)。

编排服务插件的配置文件路径为`/usr/local/etc/modelbox/modelbox.conf`，其配置项目如下：

| 配置项目               | 配置说明                                                                  |
| ---------------------- | ------------------------------------------------------------------------- |
| editor.enable          | 是否启用Editor工具                                                        |
| editor.ip              | Editor工具监听IP，默认为127.0.0.1。不指定的情况下，和server.ip一致       |
| editor.port            | Editor工具监听端口，默认为1104，不指定情况下，和server.port一致           |
| editor.root            | Editor前端UI路径，默认为/usr/local/share/modelbox/www                       |
| editor.solution_graphs | Editor solution_graphs路径，默认为/usr/local/share/modelbox/solution/graphs |

下面分别介绍两种启用Editor的方法。

### 命令行启用Editor

通过如下命令，可开启基于Web的可视化编辑工具——Editor。

```shell
modelbox-tool develop -e 
```

命令执行后，将开启http服务，可使用对应主机的IP地址，和开启的端口号（默认端口号为1104），访问Editor界面。

### 配置启用Editor

若需要定制化编排服务启动参数，可以修改配置文件，具体修改流程如下：

1. 打开`/usr/local/etc/modelbox/modelbox.conf`，修改其中的配置项：

    ```toml
    [server]
    # 允许访问服务
    ip = "0.0.0.0"
    port = "1104"
    flow_path = "/usr/local/etc/modelbox/graph"
    
    [plugin]
    # 确保Editor组件加载。
    files = [
        "/usr/local/lib/modelbox-plugin-editor.so" #
    ]
    
    [editor]
    # 启用Editor
    enable = true
    
    # 设置绑定IP和端口。
    ip = "0.0.0.0"
    port = "1104"
    
    # 指定前端UI路径，默认情况无需修改。
    root = "/usr/local/share/modelbox/www"
    solution_graphs = "/usr/local/share/modelbox/solution/graphs"
    ```

1. 重启ModelBox Server服务使配置生效。

    ```shell
    systemctl restart modelbox
    ```

## 访问编排服务

服务启动成功后，可使用浏览器访问服务，输入对应的网址即可，如：`http://[host]:1104/editor/`，成功后，将显示如下界面：

![editor-ui](../assets/images/figure/server/Editor-UI.png)

UI界面分为7个功能区域，其对应的功能如下：

1. 区域1，功能页面选择。
1. 区域2，基本编排操作区域，包含对6号区域的放大，缩小，重置大小，居中显示等操作。
1. 区域3，基础组件列表区域，安装不同的组件分类，可从此面板选择对应编排的组件。组件数量受图的FlowUnit路径和服务器中功能单元插件个数的影响。
1. 区域4，帮助和API页面的链接。
1. 区域5，图操作功能区，包含新建，保持，图属性，选择图表，和解决方案功能。
1. 区域6，图形化编排界面，使用鼠标可以控制组件链接和移动。`Ctrl+鼠标左键`可以拖动画布。
1. 区域7，对应文本化编排界面，可使用标准的[DOT](https://www.graphviz.org/pdf/dotguide.pdf)语法进行文本编辑。

快捷键说明：

1. 放大缩小：`鼠标滚轮`，或键盘，`-`，`=`按键。
1. 全选：`ctrl+a`
1. 撤销：`ctrl+z`
1. 重做：`ctrl+u`
1. 取消选择：`escape`

注意事项：

1. 对应网址的端口号以docker启动脚本中的 `EDITOR_MAP_PORT` 为准，默认端口号为1104。
1. 区域3中若无显示任务组件，请确保`图设置`界面中，选中了使用系统功能单元，和正确指定功能单元路径。
1. 编排完成后，需要点击`另存为`保存图，然后才能在任务管理界面下发任务。

## 执行编排任务

编排完成，并保存完编排图后，可在编排管理界面下发编排任务，对应的编排任务管理界面如下：

![task-ui](../assets/images/figure/server/Task-UI.png)

任务界面分为4个功能区域，其对应的功能如下：

1. 区域1，新建任务按钮，用于新建编排页面创建的图。
1. 区域2，服务器端执行的任务列表。
1. 区域3，任务执行状态。
1. 区域4，任务执行出错情况下的错误信息。

## 访问控制列表

访问控制列表ACL（Access Control List）是由一条或多条规则组成的集合，里面配置了允许访问Editor的IP地址。
可以通过修改配置文件，来修改ACL列表，具体流程如下：

1. 打开`/usr/local/etc/modelbox/modelbox.conf`，修改其中的配置项：
   假设打开编排UI的机器的IP地址为10.11.12.13

   ```shell
    [acl]
    allow = [
        "10.11.12.13",
    ]
   
    [plugin]
    files = [
        "/usr/local/lib/modelbox-plugin.so",
        "/usr/local/lib/modelbox-plugin-editor.so"
    ]
   ```
   
    如果没有配置任何访问白名单，则允许所有人皆可访问。
    ```shell
        # [acl]
        # allow = [
        #     "10.11.12.13",
        # ]
    ```
   
1. 重启ModelBox Server服务使配置生效。

    ```shell
    systemctl restart modelbox
    ```

注意：1. 确保`[editor]`下`enable = true`。