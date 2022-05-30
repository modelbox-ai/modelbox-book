# 输入类功能单元

输入类功能单元主要用于设置或者对接数据源，如视频流、文件、HTTP等，作为业务流的输入。

## video_input

### 功能描述

用于设置视频文件、视频流数据源信息。

### 设备类型

cpu

### 输入端口

无

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_video_url|string|cpu|数据源地址|

### 配置参数

|参数名称|参数类型|是否必填|参数含义|
|--|--|--|--|
|source_url|string|是|数据源地址，如文件路径、RTSP流地址|
|repeat|uint64_t|否|并发路数，默认为1|

### 约束说明

无

### 使用样例

```toml
  video_input[type=flowunit, flowunit=video_input, device=cpu, deviceid=0,  repeat=4, source_url="/xxx/xxx.mp4"]
  videodemuxer[type=flowunit, flowunit=video_demuxer, device=cpu, deviceid=0, queue_size_event=1000, label="<in_video_url> | <out_video_packet>"] 
  videodecoder[type=flowunit, flowunit=video_decoder, device=cuda, deviceid=0, pix_fmt="nv12"]
  ...  
  video_input:out_video_url -> videodemuxer:in_video_url
  videodemuxer:out_video_packet -> videodecoder:in_video_packet
  videodecoder:out_video_frame -> ...
```

## httpserver_async

### 功能描述

提供HTTP异步服务能力，接受请求后立即回复。

### 设备类型

cpu

### 输入端口

无

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_request_info|[HTTP请求数据类型](./flowunits.md#http请求数据类型)|cpu|接受HTTP请求信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义|
|--|--|--|--|
|endpoint|string|是|HTTP地址|
|max_requests|uint64_t|否|并发最大请求数，默认值为1000|
|keepalive_timeout_sec|uint64_t|否|请求保活时间，单位为秒，默认值为200|
|cert|string|否|openssl证书路径，https时使用|
|key|string|否|openssl私钥路径，https时使用|
|passwd|string|否|经过加密的openssl密码，https时使用. 密码可使用Modelbox-tool加密，详细见[ModelBox Tool](../tools/modelbox-tool/modelbox-tool.md)密码加密章节|
|key_pass|string|否|用于解密openssl密码的密钥，https时使用。详细见[ModelBox Tool](../tools/modelbox-tool/modelbox-tool.md)密码加密章节|

### 约束说明

无

### 使用样例

无

## httpserver_sync_receive

### 功能描述

提供HTTP同步请求的接受能力。

### 设备类型

cpu

### 输入端口

无

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_request_info|[HTTP请求数据类型](./flowunits.md#HTTP请求数据类型)|cpu|接受HTTP请求信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义|
|--|--|--|--|
|endpoint|string|是|HTTP地址|
|max_requests|uint64_t|否|并发最大请求数，默认值为1000|
|time_out_ms|uint64_t|否|请求超时时间，单位为毫秒，默认值为5000|
|keepalive_timeout_sec|uint64_t|否|请求保活时间，单位为秒，默认值为200|
|cert|string|否|openssl证书路径，https时使用|
|key|string|否|openssl私钥路径，https时使用|
|passwd|string|否|经过加密的openssl密码，https时使用. 密码可使用Modelbox-tool加密，详细见[ModelBox Tool](../tools/modelbox-tool/modelbox-tool.md)密码加密章节|
|key_pass|string|否|用于解密openssl密码的密钥，https时使用。详细见[ModelBox Tool](../tools/modelbox-tool/modelbox-tool.md)密码加密章节|

### 使用约束

httpserver_sync_receive 需要和 httpserver_sync_reply 组合使用，使用方式可见样例。

### 使用样例

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

## data_source_parse

### 功能描述

提供解析视频源的能力，如obs, vcn, vis, restful, url等，用于对接华为云ModelboxArts推理服务。

### 设备类型

cpu

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_data|string|cpu|数据源配置信息|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_video_url|string|cpu|视频或视频流地址|

### 配置参数

|参数名称|参数类型|是否必填|参数含义|
|--|--|--|--|
|retry_enable|bool|否|是否需要重连|
|retry_interval_ms|int32_t|否|重连间隔时间，单位为毫秒|
|retry_count_limit|int32_t|否|重连次数，-1为无限重连|

### 使用约束

data_source_parse 需要配合华为云ModelboxArts推理服务和ModelboxArts插件配合使用。data_source_parse 一般后面接videodemuxer，用于视频解封装和解码。

### 使用样例

```toml
    input1[type=input, device=cpu, deviceid=0]
    data_source_parser[type=flowunit, flowunit=data_source_parser, device=cpu, deviceid=0, retry_interval_ms = 1000] 
    videodemuxer[type=flowunit, flowunit=video_demuxer, device=cpu, deviceid=0]
    videodecoder[type=flowunit, flowunit=video_decoder, device=cpu, deviceid=0,pix_fmt=nv12]  
    ...
    input1 -> data_source_parser:in_data
    data_source_parser:out_video_url -> videodemuxer:in_video_url
    videodemuxer:out_video_packet -> videodecoder:in_video_packet
    videodecoder:out_video_frame -> ...
```

## data_source_generator

### 功能描述

提供data_source_parse的输入信息。

### 设备类型

cpu

### 输入端口

无

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_data|string|cpu|数据源配置信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义|
|--|--|--|--|
|source_type|string|是|数据源类型，取值范围："url"|
|url|string|是|数据源地址|
|url_type|string|是|文件或者视频流类型，取值范围："file"、"stream", 类型不同会影响解封装失败重连策略，视频流类型断流会自动重连，而文件类型则不会重连|

### 使用约束

data_source_generator 需要配合data_source_parse配合使用，主要用于本地调试。

### 使用样例

```toml
    data_source_gengerator[type=flowunit, flowunit=data_source_generator, device=cpu, deviceid=0, source_type="url", url="http://0.0.0.0:8080/video", url_type="file"]
    data_source_parser[type=flowunit, flowunit=data_source_parser, device=cpu, deviceid=0]
    videodemuxer[type=flowunit, flowunit=video_demuxer, device=cpu, deviceid=0]
    videodecoder[type=flowunit, flowunit=video_decoder, device=cpu, deviceid=0,pix_fmt=nv12]  
    ...
    data_source_gengerator:out_data -> data_source_parser:in_data
    data_source_parser:out_video_url -> videodemuxer:in_video_url
    videodemuxer:out_video_packet -> videodecoder:in_video_packet
    videodecoder:out_video_frame -> ...
```
