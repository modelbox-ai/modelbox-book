# 预置功能单元（详细描述流单元功能，配置参数列表，输入要求，输出格式内容，使用限制等）

ModelBox预置了多个常用功能单元，可用于完成AI应用的基本流程，开发者可以直接使用。

## 功能单元列表

按业务类型分类，ModelBox主要预置功能单元如下表所示。

|业务分类|功能单元名称|功能单元类型|功能简介
|--|--|--|--|
|输入类|[video_input](./flowunits-input.md#video_input)|NORMAL|获取视频输入地址
|输入类|[httpserver_async](./flowunits-input.md#httpserverasync)|NORMAL|收发http异步请求
|输入类|[httpserver_sync_receive](./flowunits-input.md#httpserversyncreceive)|NORMAL|接受http同步请求
|输入类|[data_source_parse](./flowunits-input.md#datasourceparse)|STREAM|解析数据源，仅对接华为云ModelArts使用
|输入类|[data_source_generator](./flowunits-input.md#datasourcegenerator)|NORMAL|产生数据源，给data_source_parse提供模拟输入，本地调试用
|输出类|[httpserver_sync_reply](./flowunits-output.md#httpserversyncreply)|STREAM|回复http同步请求
|输出类|[output_broker](./flowunits-output.md#outputbroker)|STREAM|将算法处理结果输出到外部
|视频类|[video_demuxer](./flowunits-video.md#videodemuxer)|STREAM|视频解封装
|视频类|[video_decoder](./flowunits-video.md#videodecoder)|STREAM|视频解码
|视频类|[video_encoder](./flowunits-video.md#videoencoder)|STREAM|视频编码
|图像类|[resize](./flowunits-image.md#resize)|NORMAL|图像尺寸调整
|图像类|[padding](./flowunits-image.md#padding)|NORMAL|图像填充
|图像类|[crop](./flowunits-image.md#crop)|NORMAL|对图片进行裁剪
|图像类|[mean](./flowunits-image.md#mean)|NORMAL|图像减均值
|图像类|[normalize](./flowunits-image.md#normalize)|NORMAL|图像归一化
|图像类|[image_rotate](./flowunits-image.md#imagerotate)|NORMAL|图像旋转
|图像类|[color_convert](./flowunits-image.md#colorconvert)|NORMAL|对图片进行颜色通道转换
|图像类|[image_decoder](./flowunits-image.md#imagedecoder)|NORMAL|图像解码
|图像类|[image_preprocess](./flowunits-image.md#imagepreprocess)|NORMAL|图像尺寸调整
|图像类|[draw_bbox](./flowunits-image.md#drawbbox)|NORMAL|在图像上画框
|通用类|[buff_meta_mapping](./flowunits-generic.md#buffmetamapping)|STREAM|做元数据映射
|虚拟类|[inference](./flowunits-virtual.md#inference)|NORMAL|模型推理虚拟功能单元模板, 用于创建推理功能单元
|虚拟类|[yolo_postprocess](./flowunits-virtual.md#yolopostprocess)|NORMAL|yolo后处理模板,用于创建yolo模型后处理功能单元
|虚拟类|[input](./flowunits-virtual.md#input)|不涉及|虚拟输入功能单元，用于接受图外部输入
|虚拟类|[output](./flowunits-virtual.md#output)|不涉及|虚拟输出功能单元，用于数据输出到图外部

## 常用数据类型

Modelbox框架定义了一些通用数据类型，用于规定预置功能单元的输入数据和输出数据格式要求，每一种数据类型规定了该类型的buffer数据应该携带的buffer meta字段信息。

### Tensor数据类型

含义：基础数据类型。

buffer meta字段信息：

|参数名称|参数类型|参数含义|
|--|--|--|  
|shape|vector&lt;size_t&gt;|多维数据的每一维取值|
|type|可取值：ModelBoxDataType::MODELBOX_UINT8、ModelBoxDataType::MODELBOX_FLOAT|buffer data数据类型|

### 图片数据类型

含义：描述一张图片的属性，图片数据类型包含Tensor数据类型信息。

buffer meta字段信息：

|参数名称|参数类型|参数含义|
|--|--|--|
|width|int32_t|图片宽|
|height|int32_t|图片高|
|width_stride|int32_t|对齐后的图片宽，目前仅用于ascend类型buffer|
|height_stride|int32_t|对齐后的图片高，目前仅用于ascend类型buffer|
|channel|int32_t|图像通道数|
|pix_fmt|string|图像格式，取值范围："rgb"、"bgr"、"nv12"、"rgbp"、"bgrp"、"gray"|
|layout|int32_t|图片布局，取值范围：hwc、hcw|
|shape|vector&lt;size_t&gt;|多维数据的每一维取值|
|type|ModelBoxDataType::MODELBOX_UINT8|buffer data数据类型|

### 视频帧数据类型

含义：描述视频解码后的每帧图片的属性，包含视频信息和图片数据类型信息。

buffer meta字段信息：

|参数名称|参数类型|参数含义|
|--|--|--|
|index|int64_t|帧编号|
|rate_num|int32_t|帧率分子，帧率为rate_num/rate_den |
|rate_den|int32_t|帧率分母, 帧率为rate_num/rate_den |
|rotate_angle|int32_t|画面旋转角度 |
|duration|int64_t|视频时长|
|url|int32_t|视频源路径|
|timestamp|int64_t|时间戳|
|eos|int32_t|结束标识|
|width|int32_t|图片宽|
|height|int32_t|图片高|
|width_stride|int32_t|对齐后的图片宽，目前仅用于ascend类型buffer|
|height_stride|int32_t|对齐后的图片高，目前仅用于ascend类型buffer|
|channel|int32_t|图像通道数|
|pix_fmt|string|图像格式，取值范围："rgb"、"bgr"、"nv12"、"rgbp"、"bgrp"、"gray"|
|layout|int32_t|图片布局，取值范围：hwc、hcw|
|shape|vector&lt;size_t&gt;|多维数据的每一维取值|
|type|ModelBoxDataType::MODELBOX_UINT8|buffer data数据类型|

### 视频包数据类型

含义：描述视频解封装后的数据包，用于视频解码。

buffer meta字段信息：
|参数名称|参数类型|参数含义|
|--|--|--|
|pts|int64_t|显示时间|
|dts|int64_t|解码时间|
|rate_num|int32_t|帧率分子，帧率为rate_num/rate_den |
|rate_den|int32_t|帧率分母, 帧率为rate_num/rate_den |
|duration|int64_t|视频时长|
|time_base|double|基准时间，单位为秒|
|width|int32_t|视频宽|
|height|int32_t|视频高|

### 矩形框数据类型

含义：描述矩形区域。

buffer meta字段信息：无

buffer data信息存放结构如下：

``` c++
typedef struct RoiBox {
  int32_t x, y, w, h;
} ;
```

### 检测矩形框类型

含义：描述yolo检测的结果，包含矩形区域、置信度、分类结果。

buffer meta字段信息：无

buffer data信息信息存放结构如下。

``` c++
typedef struct BoundingBox {
 public:
  float x;
  float y;
  float w;
  float h;
  int32_t category;
  float score;
};
```

### HTTP请求数据类型

含义：描述HTTP请求数据类型。

buffer meta字段信息：

|参数名称|参数类型|参数含义|
|--|--|--|
|size|size_t|请求体数据大小|
|method|string|请求方法|
|url|string|请求url|
|headers|map<string,string>|请求头信息|
|endpoint|string|请求endpoint|

### HTTP请求响应数据类型

含义：描述HTTP请求响应数据类型。

buffer meta字段信息：

|参数名称|参数类型|参数含义|
|--|--|--|
|status|int32_t|返回状态码，暂不支持|
|headers|map<string,string>|请求头信息,暂不支持|

## 查询功能单元命令

开发者可以通过Modelbox Tool命令查询各个功能单元的详细信息，包括功能介绍、cpu/cuda类型、输入要求、输出信息、配置项、约束等。命令如下：

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

<<<<<<< Updated upstream

# （章节目录参考）

# Resize流单元

功能说明，描述流单元功能，输入什么得到什么，使用限制

## 流单元配置

描述option有哪些参数可配置，含义，默认值，是否必选，可用表格列举

## 输入

输入要求，buffer格式，meta必须带的参数等

## 输出

输出buffer内容，meta内容等

## 使用示例

```txt
  img_resize[type=flowunit, flowunit=resize, device=cpu/cuda, image_height=xxx, image_width=xxx]

  xxx -> xxx
  img -> img_resize:in_image
  img_resize:out_image -> out
  xxx
```

=======
>>>>>>> Stashed changes
