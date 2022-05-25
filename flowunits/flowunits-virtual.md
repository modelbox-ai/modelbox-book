# 虚拟类功能单元

虚拟类功能单元是只由Modelbox提供的一类特殊的功能单元，目前主要分两类：
模板类功能单元和输入输出虚拟功能单元。
<br>模板类功能单元是基于一些相似功能的通用功能单元抽象出来的一个功能单元模板，它不能直接使用，需要通过配置文件实例化之后就可以当作正常功能使用。当前模板类功能单元主要有：inference、yolo_postprocess。
<br>输入输出虚拟功能单元是简化的功能单元 仅提供接受数据的功能，它没有端口、配置等功能单元属性等。主要用于流程图，当前输入输出虚拟功能单元有：input、output。

## inference

### 功能描述

提供模型推理的模板，只需要填写配置文件和提供模型，即可实现模型推理功能单元，详细介绍可详见[推理功能单元]章节(../flowunit/inference.md)

### 设备类型

cpu、cuda、ascend

### 使用说明

实现自定义推理功能单元：编写配置文件，配置文件说明可详见[推理功能单元]章节(../flowunit/inference.md)
<br>
图连接：编写完成toml文件后，将对应的路径加入ModelBox的图配置中的搜索路径即可使用开发后的推理功能单元。推理功能单元的输入端口和输出端口名称和个数的由toml文件指定，当模型存在多输入或者多输出时，图构建时需要针对每个输入端口和输出端口进行接口连接。

### 使用约束

无

### 使用样例

```toml
    ...
    face_pre[type=flowunit, flowunit=face_post, device=cpu]
    model_detect[type=flowunit, flowunit=model_detect, device=cuda]
    yolobox_name[type=flowunit, flowunit=yolobox_name, device=cpu]
    ...
    face_pre:out_port1 -> model_detect:input1
    face_pre:out_port2 -> model_detect:input2
    model_detect:output1 -> yolobox_name:in_port1
    model_detect:output2 -> yolobox_name:in_port2
    yolobox_name:out_port1 -> ...
    ...
```

## yolo_postprocess

### 功能描述

提供yolo模型后处理的模板，只需要填写配置文件，即可实现yolo模型的后处理功能单元

### 设备类型

cpu

### 使用说明

实现自定义功能单元：编写配置文件，配置文件说明如下

```toml
# 基础配置
[base]
name = "yolobox_name"  # 功能单元名称
version = "1.0.0"  # 功能单元组件版本号
description = "a common cpu yolobox flowunit" # 功能单元功能描述信息
type = "yolo_postprocess"  # yolo_postprocess类型功能单元标识
virtual_type = "yolov3_postprocess"  # yolo后处理类型，当前只支持yolov3_postprocess，后续可扩展其他yolo版本类型
device = "cpu" # 当前只支持cpu

# yolo后处理配置
[config]   
input_width = 800
input_height = 480
class_num = 1
score_threshold = ["0.6","0.7"]
nms_threshold = ["0.45","0.3"]
yolo_output_layer_num = 2
yolo_output_layer_wh = ["25","15","50","30"]
anchor_num = ["4","4"]
anchor_biases = ["100.0","72.0","173.12","55.04","165.12","132.0","280.0","252.0"," 10.0","8.0","20.0","16.0","30.0","24.0","67.0","56.0"]

# 功能单元输入配置
[input]
[input.input1]
name = "in_1"
[input.input2]
name = "in_2"

# 功能单元输出配置
[output]
[output.output1]
name = "out_1"
```

图连接：编写完成toml文件后，将对应的路径加入ModelBox的图配置中的搜索路径即可使用开发后的yolo_postprocess功能单元。yolo_postprocess功能单元的输入端口和输出端口名称和个数的由toml文件指定，当存在多输入或者多输出时，图构建时需要针对每个输入端口和输出端口进行接口连接。

### 使用约束

无

### 使用样例

```toml
    ...
    face_pre[type=flowunit, flowunit=face_post, device=cpu]
    model_detect[type=flowunit, flowunit=model_detect, device=cuda]
    yolobox_name[type=flowunit, flowunit=face_post, device=cpu]
    ...
    face_pre:out_port1 -> model_detect:input1
    face_pre:out_port2 -> model_detect:input2
    model_detect:output1 -> yolobox_name:in_port1
    model_detect:output2 -> yolobox_name:in_port2
    yolobox_name:out_port1 -> ...
    ...
```

## input

### 功能描述

用于接受外部数据并向后转发。主要用于Modelbox Plugin 向流程图发送数据的入口。

### 设备类型

cpu

### 使用说明

定义input类型功能单元格式：flowunit_name[type=input]
<br>
input类型功能单元端口连接：可直接通过flowunit name进行端口间的链接，如 flowunit_name-> next_flowunit:in_port

### 使用约束

无

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

## output

### 功能描述

用于接受结果数据并向外发送，主要用于Modelbox Plugin 接受流程图结果数据的出口。另外由于图构建时所有输入输出端口都必须存在连接关系，当具备输出端口的功能单元想作为最后一个功能单元时会校验失败，此时output可以适配器接在端口后。

### 设备类型

cpu

### 使用说明

定义output类型功能单元格式：flowunit_name[type=output]
<br>
output类型功能单元端口连接：可直接通过flowunit name进行端口间的链接，如 pre_flowunit:out_port -> flowunit_name

### 使用约束

无

### 使用样例

```toml
    input1[type=input]
    data_source_parser[type=flowunit, flowunit=data_source_parser, device=cpu, deviceid=0, retry_interval_ms = 1000] 
    videodemuxer[type=flowunit, flowunit=video_demuxer, device=cpu, deviceid=0]
    videodecoder[type=flowunit, flowunit=video_decoder, device=cpu, deviceid=0,pix_fmt=nv12]  
    output1[type=output]
    input1 -> data_source_parser:in_data
    data_source_parser:out_video_url -> videodemuxer:in_video_url
    videodemuxer:out_video_packet -> videodecoder:in_video_packet
    videodecoder:out_video_frame -> output1
```
