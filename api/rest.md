# REST API

ModelBox Server启动后之后，ModelBox Plugin就开始对外提供服务，服务的endpoint为`http://server.ip:server.port`，其中server.ip和server.port为ModelBox服务运行配置中的配置项，默认为`http://127.0.0.1:1104`，服务的path为`/v1/modelbox/job`，业务可通过发送REST请求到插件管理流程图。

ModelBox服务当前提供动态增加flow作业，动态删除flow作业，查询所有flow作业列表，查询flow作业状态

## 增加flow作业

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
  * `job_graph`：toml格式的图信息，graph的配置详见[图](../framework-conception/graph.md)

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
            "          httpserver_sync_receive[type=flowunit, flowunit=httpserver_sync_receive, device=cpu, deviceid=0, endpoint=\"http://127.0.0.1:8080/example\", max_requests=10, time_out=5000]",
            "          httpserver_sync_reply[type=flowunit, flowunit=httpserver_sync_reply, device=cpu, deviceid=0]",
            "          httpserver_sync_receive:out_request_info -> httpserver_sync_reply:in_reply_info",
            "  }"
          ]
        },
        "driver": {
          "dir": "",
          "skip-default": "false"
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

  * `error_code`：错误码，参考[错误码](run-flow.md#错误码)
  * `error_msg`：错误码对应的消息。

## 查询flow作业状态

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

## 删除flow作业

* REST API

  URI: `http://server.ip:server.port/v1/modelbox/job/[flow-name]`

* 返回值

  * 正常返回HTTP code 204。
  * 异常返回错误json。

* 例子

  命令： `curl -X DELETE http://127.0.0.1:1104/v1/modelbox/job/flow-example`

## 查询所有flow作业列表

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

  * `job_list`: flow列表。

## flow作业状态码

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

## 错误码

当前支持的错误码：

| 错误码       | 错误码说明                         |
| ------------ | ---------------------------------- |
| MODELBOX_001 | server internal error              |
| MODELBOX_002 | request invalid, no such job       |
| MODELBOX_003 | request invalid, can not get jobId |
| MODELBOX_004 | request invalid, can not get graph |
| MODELBOX_005 | request invalid, job already exist |
| MODELBOX_006 | request invalid, invalid command   |
