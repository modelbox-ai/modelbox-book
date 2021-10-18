# 运行流程图

## ModelBox Plugin插件

ModelBox Plugin插件用于对外提供服务，管理并运行流程图。此插件内置在Modelbox Server中。

默认情况下，可以直接使用此插件执行相关的流程图功能。例如，新建任务后，将使用插件运行流程图，并将结果对外输出。

* ModelBox Plugin功能说明：

![plugin-feature](../assets/images/figure/server/plugin-feature.png)

ModelBox Plugin主要提供两个功能。

1. 添加配置文件管理流程图。
2. 调用REST API执行流程图。

### ModelBox Plugin插件配置

ModelBox Plugin插件配置文件和ModelBox Server主配置文件相同，即为`/usr/local/etc/modelbox/modelbox.conf`, ModelBox Plugin插件的配置项目如下：

| 配置项目         | 配置说明                                                                   |
| ---------------- | -------------------------------------------------------------------------- |
| server.ip        | ModelBox Plugin绑定的管理IP地址，默认为127.0.0.1                             |
| server.port      | ModelBox Plugin绑定的管理端口，默认为1104                                    |
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

配置文件复制到图存储目录后，可执行ModelBox Server服务重启命令`systemctl restart modelbox`生效。

注意：

  1. ModelBox服务加载该目录下的所有文件作为flow作业，如果加载失败将跳过该flow，文件名将作为flow的作业名。
  1. 文件名不要包含特殊符号，并且后缀名为`.toml`。
  1. 如果修改该配置项，需要保证指定的目录存在并具有读权限，否则将加载失败。
  1. 路径可通过`server.flow_path`参数修改。

## 图形化运行流程图

请参考[运行编排服务](editor.md)。

## REST API管理执行流程图

ModelBox Server启动后之后，ModelBox Plugin就开始对外提供服务，服务的endpoint为`http://server.ip:server.port`，其中server.ip和server.port为ModelBox服务运行配置中的配置项，默认为`http://127.0.0.1:1104`，服务的path为`/v1/modelbox/job`，业务可通过发送REST请求到插件管理流程图。

ModelBox服务当前提供动态增加flow作业，动态删除flow作业，查询所有flow作业列表，查询flow作业状态

### 增加flow作业

* REST API

  URI: `http://server.ip:server.port/v1/modelbox/job/`
  METHOD: `POST`

* REST API BODY

  ```json
  {
      "job_id": "flow2",
      "job_graph": "xxxxx"
  }
  ```

  * `job_id`： flow名字，用户自定义，建议不要包含特殊字符。
  * `job_graph`：toml格式的图信息，graph的配置详见[图](../framework-conception/graph.md)。

* 例子

  命令：`curl -X PUT --data @flow-example  http://127.0.0.1:1104/v1/modelbox/job`

  flow-example文件内容：
  
  ```json
  {
      "job_id": "flow-example",
      "job_graph": {
        "graph": {
          "format":"graphviz",
          "graphconf": [
            " digraph demo { ",
            "          httpserver_sync_receive[type=flowunit, flowunit=httpserver_sync_receive, device=cpu, deviceid=0, label=\"<Out_1>\", request_url=\"http://localhost:54321/example\", max_requests=10, time_out=5]",
            "          httpserver_sync_reply[type=flowunit, flowunit=httpserver_sync_reply, device=cpu, deviceid=0, label=\"<In_1>\"]",
            "          httpserver_sync_receive:out_request_info -> httpserver_sync_reply:in_reply_info,
            "  }"
          ]
        },
        "driver": {
          "dir": "/usr/local/lib/"
        }
      }
  }
  ```

* 返回值

  * 正常返回HTTP code 201。
  * 异常返回错误json：

    ```json
    {
        "error_code": "[some error code]",
        "error_msg" : "[some error message]"
    }
    ```

  * `error_code`：错误码，参考[错误码](run-flow.md#错误码)。
  * `error_msg`：错误码对应的消息。

### 查询flow作业状态

* REST API

  URI: `http://server.ip:server.port/v1/modelbox/job/[flow-name]`

* REST API RESPONSE

  正常返回HTTP code 200，如下json：

  ```json
  {
      "job_status": "RUNNING",
      "job_id": "[flow-name]"
  }
  ```

  * `job_status`： flow的状态代码。
  * `job_id`：flow名称。

* 例子

  命令：`curl http://127.0.0.1:1104/v1/modelbox/job/flow-example`

### 删除flow作业

* REST API

  URI: `http://server.ip:server.port/v1/modelbox/job/[flow-name]`

* 返回值

  * 正常返回HTTP code 204。
  * 异常返回错误json。

* 例子

  命令： `curl -X DELETE http://127.0.0.1:1104/v1/modelbox/job/flow-example`

### 查询所有flow作业列表

* REST API

  URI: `http://server.ip:server.port/v1/modelbox/job/list/all`

* 例子

  命令: `curl http://127.0.0.1:1104/v1/modelbox/job/list/all`

* REST API BODY

  ```json
  {
      "job_list": [
        {
        "job_status": "RUNNING",
        "job_id": "[flow-name1]"
        },
        {
        "job_status": "RUNNING",
        "job_id": "[flow-name2]"
        }
      ]
  }
  ```

  * `job_list`: flow列表

### flow作业状态码

| 状态码    | 状态码说明   |
| --------- | ------------ |
| CREATEING | 正在创建任务 |
| RUNNING   | 任务正在执行 |
| SUCCEEDED | 任务执行成功 |
| FAILED    | 任务执行失败 |
| PENDING   | 等待执行     |
| DELETEING | 正在删除任务 |
| UNKNOWN   | 未知状态     |
| NOTEXIST  | 任务不存在   |

### 错误码

当前支持的错误码：

| 错误码     | 错误码说明                         |
| ---------- | ---------------------------------- |
| MODELBOX_001 | server internal error              |
| MODELBOX_002 | request invalid, no such job       |
| MODELBOX_003 | request invalid, can not get jobId |
| MODELBOX_004 | request invalid, can not get graph |
| MODELBOX_005 | request invalid, job already exist |
| MODELBOX_006 | request invalid, invalid command   |
