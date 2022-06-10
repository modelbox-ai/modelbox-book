# 配置类功能单元

配置类功能单元是只由Modelbox提供的一类特殊的功能单元。

配置类功能单元是基于一些相似功能的通用功能单元抽象出来的一个功能单元模板，它不能直接使用，需要通过配置文件实例化之后就可以当作正常功能使用。当前模板类功能单元主要有：inference、yolo_postprocess。

## yolo_postprocess

- 功能描述

提供yolo模型后处理的模板，只需要填写配置文件，即可实现yolo模型的后处理功能单元

- 设备类型

cpu

- 使用说明

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

- 约束说明

无

- 使用样例

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
