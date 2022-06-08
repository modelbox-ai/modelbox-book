# 输出类功能单元

输出类功能单元主要用于业务处理结果的发送。

## httpserver_sync_reply

- 功能描述

提供HTTP同步请求的回复能力。

- 设备类型

cpu

- 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义
|--|--|--|--|
|in_reply_info|[HTTP请求响应数据类型](./flowunits.md#HTTP请求响应数据类型)|cpu|回复HTTP请求信息

- 输出端口

无

- 配置参数

无

- 约束说明

httpserver_sync_reply 需要和 httpserver_sync_receive  组合使用，使用方式可见样例。

- 使用样例

```toml
    httpserver_sync_receive[type=flowunit, flowunit=httpserver_sync_receive, device=cpu, time_out_ms=5000, endpoint="http://0.0.0.0:8080", max_requests=100]
    mnist_preprocess[type=flowunit, flowunit=mnist_preprocess, device=cpu]
    mnist_infer[type=flowunit, flowunit=mnist_infer, device=cpu, deviceid=0, batch_size=1]
    mnist_response[type=flowunit, flowunit=mnist_response, device=cpu]
    httpserver_sync_reply[type=flowunit, flowunit=httpserver_sync_reply, device=cpu]

    httpserver_sync_receive:out_request_info -> mnist_preprocess:in_data
    mnist_preprocess:out_data -> mnist_infer:input
    mnist_infer:output -> mnist_response:in_data
    mnist_response:out_data -> httpserver_sync_reply:in_reply_info
```

## output_broker

- 功能描述

提供HTTP同步请求的回复能力。

- 设备类型

cpu

- 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义
|--|--|--|--|
|in_output_info|buffer meta信息:<br>字段名称：output_broker_names <br> 字段类型：string <br> 字段含义：输出目标类型 <br> buffer data信息:待发送数据 |cpu|需要发送的数据信息

- 输出端口

无

- 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|retry_count_limit|int64_t|否|失败重试次数|
|retry_interval_base_ms|uint64_t|否|第一次重试间隔时间，单位为毫秒|
|retry_interval_increment_ms|uint64_t|否|重试间隔递增时间，单位为毫秒|
|retry_interval_limit_ms|uint64_t|否|最大重试间隔时间，单位为毫秒|

- 约束说明

output_broker 需要配合华为云ModelboxArts推理服务和ModelboxArts插件配合使用。

- 使用样例

无
