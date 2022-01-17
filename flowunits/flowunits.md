# 预置功能单元

ModelBox预置了多个通用功能单元，可用于完成AI推理算法的基本流程，开发者可以直接使用。

按业务类型分类，ModelBox主要预置FlowUnit如下表所示。

| 业务分类     | 功能单元名称                                        | 功能简介                         |
| ------------ | --------------------------------------------------- | -------------------------------- |
| 输入类       | [data_source_parse](#data_source_parse功能单元)     | 解析外部到算法流水线的输入       |
| 输入类       | [video_input](#video_input功能单元)                 | 获取视频输入地址                 |
| 输出类       | [output_broker](#output_broker功能单元)             | 将算法处理结果输出到外部         |
| 网络收发类   | [httpserver_async](#httpserver_async功能单元)       | 收发http异步请求                 |
| 网络收发类   | [httpserver_sync_receive](#httpserver_sync功能单元) | 接受http同步请求                 |
| 网络收发类   | [httpserver_sync_reply](#httpserver_sync功能单元)   | 回复http同步请求                 |
| 视频类       | [video_decoder](#videodecoder功能单元)              | 视频解码                         |
| 视频类       | [video_demuxer](#videodemuxer功能单元)              | 视频解封装                       |
| 视频类       | [video_encoder](#videoencoder功能单元)              | 视频编码                         |
| 图像类       | [color_convert](#color_transpose功能单元)           | 对图片进行颜色通道转换           |
| 图像类       | [crop](#crop功能单元)                               | 对图片进行裁剪                   |
| 图像类       | [draw_bbox](#draw_bbox功能单元)                     | 在图像上画框                     |
| 图像类       | [image_decoder](#image_decoder功能单元)             | 图像解码                         |
| 图像类       | [mean](#mean功能单元)                               | 图像减均值                       |
| 图像类       | [normalize](#normalize功能单元)                     | 图像标准化                       |
| 图像类       | [padding](#padding功能单元)                         | 图像填充                         |
| 图像类       | [resize](#resize功能单元)                           | 图像尺寸调整                     |
| 图像类       | [image_preprocess](#resize功能单元)                 | 图像尺寸调整                     |
| 推理类       | [inference](#inference功能单元)                     | 模型推理功能单元                 |
| 后处理类     | [yolov3_postprocess](#common_yolobox功能单元)       | 从yolov3模型中获取检测目标的信息 |
| buffer处理类 | [buff_meta_mapping](#meta_mapping功能单元)          | 做元数据映射                     |

开发者可以通过ModelBox Tool命令查询各个功能单元的详细信息，包括功能介绍、CPU/GPU类型、输入要求、输出信息、配置项、约束等。命令如下：
查询当前系统目录下所有可以加载的功能单元列表：

```shell
modelbox-tool driver -info -type flowunit
```

查询单个功能单元详细信息：

```shell
modelbox-tool driver -info -type flowunit -detail -name xxx
```

查询当前系统目录和用户自定义路径下所有可以加载的功能单元列表：

```shell
modelbox-tool driver -info -type flowunit -path xxx
```

命令帮助信息：

```shell
modelbox-tool driver
```

以resize功能单元为例，查询详细结果字段含义如下：

```shell
[root@996a6346d170 modelbox]$ modelbox-tool driver -info -type flowunit -detail -name resize
--------------------------------------
flowunit name   : resize # flowunit名称
type            : cpu    # flowunit类型：cpu：普通cpu; cuda：nvidia gpu; ascend： ascend d310推理加速卡
driver name     : resize # driver名称：c++场景一个driver对应一个so，一个driver可以包含多个flowunit
version         : 1.0.0
descryption     :        
        @Brief: A resize flowunit on cpu                            # flowunit 功能简介
        @Port paramter: the input port buffer type and the output port buffer type are image. 
          The image type buffer contain the following meta fields:  # flowunit 输入输出数据格式
                Field Name: width,         Type: int32_t
                Field Name: height,        Type: int32_t
                Field name: width_stride,  Type: int32_t
                Field name: height_stride, Type: int32_t
                Field name: channel,       Type: int32_t
                Field name: pix_fmt,       Type: string
                Field name: layout,        Type: int32_t
                Field name: shape,         Type: vector<size_t>
                Field name: type,          Type: ModelBoxDataType::MODELBOX_UINT8
        @Constraint: the field value range of this flowunit support：'pix_fmt': [rgb_packed,bgr_packed], 'layout': [hwc].                                            # flowunit 使用约束
group           : Image        # flowunit 使用约束
inputs          :        # flowunit 输入端口列表   
  input index   : 1
    name        : in_image     # 输入端口名称
    type        :              # 输入端口类型，预留
    device      : cpu          # 输入端口数据存放设备要求
outputs         :        # flowunit 输出端口列表   
  output index  : 1
    name        : out_image    # 输出端口名称
    device      : cpu          # 输出端口数据存放位置
options         :        # flowunit支持的图配置参数
  option        : 1
    name        : image_width   # 配置参数名称
    default     : 640              # 配置参数默认值
    desc        : the resize width # 配置参数含义描述
    required    : true             # 配置参数是否必填
    type        : int              # 配置参数类型
  option        : 2
    name        : image_height
    default     : 480
    desc        : the resize height
    required    : true
    type        : int
  option        : 3
    name        : interpolation
    default     : inter_linear
    desc        : the resize interpolation method
    required    : true
    type        : list             # 配置参数枚举类型
        inter_area      : inter_area     # 配置参数枚举含义
        inter_cubic     : inter_cubic
        inter_lanczos4  : inter_lanczos4
        inter_linear    : inter_linear
        inter_max       : inter_max
        inter_nearest   : inter_nearest
        warp_fill_outliers      : warp_fill_outliers
        warp_inverse_map        : warp_inverse_map
```
