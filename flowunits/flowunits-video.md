# 视频类功能单元

视频类功能单元主要用于视频编解码。

## video_demuxer

### 功能描述

用于设置视频文件或者视频流的解封装。

### 设备类型

cpu

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_video_url|string|cpu|数据源地址|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_video_packet|[视频包数据类型](./flowunits.md#预置功能单元##常用数据类型###视频包数据类型)|cpu|解封装后的视频包，一次输入产生多次输出，直至解封装完成|

### 配置参数

无

### 约束说明

video_demuxer 一般后面连接 video_decoder ，用于视频解码功能。

### 使用样例

```toml
  video_input[type=flowunit, flowunit=video_input, device=cpu, deviceid=0, label="<out_video_url>", repeat=4, source_url="/xxx/xxx.mp4"]
  videodemuxer[type=flowunit, flowunit=video_demuxer, device=cpu, deviceid=0, queue_size_event=1000, label="<in_video_url> | <out_video_packet>"] 
  videodecoder[type=flowunit, flowunit=video_decoder, device=cuda, deviceid=0, label="<in_video_packet> | <out_video_frame>", pix_fmt="nv12"]
  ...
  video_input:out_video_url -> videodemuxer:in_video_url
  videodemuxer:out_video_packet -> videodecoder:in_video_packet
  videodecoder:out_video_frame -> ...
```

## video_decoder

### 功能描述

用于设置视频文件或者视频流的解码。

### 设备类型

cpu、cuda、ascend

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_video_packet|[视频包数据类型](./flowunits.md#预置功能单元##常用数据类型###视频包数据类型)|cpu|解封装后的视频包|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_video_frame|[视频帧数据类型](./flowunits.md#预置功能单元##常用数据类型###视频帧数据类型)|与功能单元设备类型一致|解码后的视频帧信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|pix_fmt|string|是|解码图片的格式，取值范围为"nv12", "rgb", "bgr"。注意ascend只支持"nv12"格式|

### 约束说明

1. video_decoder 一般在前面连接 video_demuxer ，用于视频解码功能。
1. ascend硬件只支持解码图片格式为"nv12"。

### 使用样例

```toml
  video_input[type=flowunit, flowunit=video_input, device=cpu, deviceid=0, label="<out_video_url>", repeat=4, source_url="/xxx/xxx.mp4"]
  videodemuxer[type=flowunit, flowunit=video_demuxer, device=cpu, deviceid=0, queue_size_event=1000, label="<in_video_url> | <out_video_packet>"] 
  videodecoder[type=flowunit, flowunit=video_decoder, device=cuda, deviceid=0, label="<in_video_packet> | <out_video_frame>", pix_fmt="nv12"]
  ...
  video_input:out_video_url -> videodemuxer:in_video_url
  videodemuxer:out_video_packet -> videodecoder:in_video_packet
  videodecoder:out_video_frame -> ...
```

## video_encoder

### 功能描述

用于设置视频文件或者视频流的编码。

### 设备类型

cpu

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_video_frame|[图片数据类型](./flowunits.md#预置功能单元##常用数据类型###图片数据类型)|cpu|解封装后的视频包|

### 输出端口

无

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|default_dest_url|string|是|视频编码的流路径或者文件路径|
|format|string|是|编码输出类型，取值范围为"rtsp", "flv", "mp4"|
|encoder|string|否|视频编码格式，默认值为 "mpeg4"|

### 约束说明

无

### 使用样例

```toml
    ...
    videoencoder[type=flowunit, flowunit=video_encoder, device=cpu, deviceid=0, encoder=mpeg4, format=mp4, default_dest_url="/tmp/car_detection_result.mp4"]
    ... -> videoencoder:in_video_frame
```
