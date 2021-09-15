# FlowUnits

ModelBox预置了多个FlowUnit（也可称为流单元），可完成AI推理算法的基本流程。本章简要介绍所有预置FlowUnit，及其主要功能、输入输出、配置、约束等内容。

按业务类型分类，ModelBox所有预置FlowUnit如下表所示。FlowUnit的使用案例，可参考[流单元连接案例](#流单元连接案例)。

|业务分类|流单元名称|功能简介
|--|--|--|
|输入类|[data_source_parse](#data_source_parse流单元)|解析外部到算法流水线的输入
|输入类|[video_input](#video_input流单元)|获取视频输入地址
|输出类|[output_broker](#output_broker流单元)|将算法处理结果输出到外部
|网络收发类|[httpserver_async](#httpserver_async流单元)|异步收发http请求
|网络收发类|[httpserver_sync](#httpserver_sync流单元)|同步收发http请求
|视频类|[videodecoder](#videodecoder流单元)|视频解码
|视频类|[videodemuxer](#videodemuxer流单元)|视频解封装
|视频类|[videoencoder](#videoencoder流单元)|视频编码
|图像类|[color_transpose](#color_transpose流单元)|对图片进行颜色通道转换
|图像类|[crop](#crop流单元)|对图片进行裁剪
|图像类|[draw_bbox](#draw_bbox流单元)|在图像上画框
|图像类|[image_decoder](#image_decoder流单元)|图像解码
|图像类|[mean](#mean流单元)|图像减均值
|图像类|[normalize](#normalize流单元)|图像标准化
|图像类|[padding](#padding流单元)|图像填充
|图像类|[resize](#resize流单元)|图像尺寸调整
|推理类|[inference](#inference流单元)|模型推理
|后处理类|[common_yolobox](#common_yolobox流单元)|从yolo模型中获取检测目标的信息
|后处理类|[yolobox](#yolobox流单元)|从yolo模型中获取检测目标的信息
|buffer处理类|[meta_mapping](#meta_mapping流单元)|做元数据映射

---

## color_transpose流单元

功能

对图片进行颜色通道转换。

输入

待处理的图片。

输出

颜色空间转换后的图片。

配置

GPU版本color_transpose流单元，输入输出配置：label，需设置为input|output，输出图片颜色类型配置：out_pix_fmt，需设置为gray、rgb或bgr中的一种。

CPU版本color_transpose流单元，输入输出配置：label，需设置为in_image|out_image。

约束

目前GPU版本color_transpose流单元仅支持以下图片类型：

三通道（bgr, rgb）和单通道（gray）UINT8类型的图像。

---

## common_yolobox流单元

功能

从yolo模型中得到检测目标的信息，包括检测框、置信度、类别等

输入

yolo模型输出层参数，包含类别数、阈值等信息的配置文件

输出

目标检测框坐标、置信度、类别等

配置

输入输出配置：label，需设置模型输出层名称，例如layer15_conv|layer22_conv|Out_1

约束

为CPU流单元

---

## crop流单元

功能

对图片进行裁剪。

输入

待裁剪的图片，裁剪坐标。

输出

裁剪后的图片。

配置

CPU版本crop流单元，流单元名称配置为：flowunit=cv_crop，输入输出配置：label，需设置为In_img|In_box|Out_img。

GPU版本crop流单元，流单元名称配置为：flowunit=nppi_crop，输入输出配置：label，需设置为In_img|In_box|Out_img，方法配置：method，目前只支持u8c3r。

ascend版本crop流单元，流单元名称配置为：flowunit=crop，输入输出配置：label，需设置为in_img|in_box|out_img。

约束

目前CPU、GPU版crop流单元支持的输入输出图片为rgb或bgr三通道图像，ascend版本支持的输出格式为rgb、bgr、nv12、nv21。

---

## data_source_parse流单元

功能

解析外部到算法流水线的输入，目前主要支持视频输入。

输入

外部输入配置(data_source_cfg)

输出

取视频流或视频文件的url地址(stream_meta)

配置

输入可以配置为obs、restful、url、vcn、vis。

约束

目前此流单元仅接收视频类型输入，obs、vcn、vis需购买相应的华为云服务。

---

## draw_bbox流单元

功能

在图像上画框。

输入

待处理的图片，画框坐标。

输出

画框后的图片。

配置

输入输出配置：label，需设置为In_1 | In_2 | Out_1。

约束

为CPU流单元。

---

## httpserver_async流单元

功能

接收http请求，并异步返回响应结果。

输入

http请求的uri、head、body等信息。

输出

发送请求是否成功的响应状态值。

配置

http请求的地址和端口（request_url，如"https://localhost:56789"），证书（cert），密钥（key），密码（passwd），密钥解密字符（key_pass），最大请求数量（max_requests）。
约束
为CPU流单元。https请求时必须配置密钥证书认证。

---

## httpserver_sync流单元

功能

接收http请求，并同步返回处理结果。

输入

http请求的uri、head、body等信息。

输出

算法返回的处理结果和响应状态。

配置

http请求的地址和端口（request_url，如"https://localhost:56789"），证书（cert），密钥（key），密码（passwd），密钥解密字符（key_pass），最大请求数量（max_requests）。
约束
https请求时必须配置密钥证书认证。

---

## image_decoder流单元

功能

图像解码流单元

输入

待解码的图像数据，packet流

输出

解码后的图像数据

配置

CPU版本，解码方式，如method="imread_color"；GPU版本，输出图片格式，如pixel_format="bgr"。

约束

CPU版本解码方式只支持以下几种："imread_color", "imread_anycolor", "imread_reduced_dolor_2","imread_reduced_color_4", "imread_reduced_color_8"，支持的输出图片格式为bgr、rgb、yuv；GPU版本支持bgr、rgb。

---

## inference流单元

功能

模型推理

输入

Tensor

输出

Tensor

配置

约束

目前支持的TensorFlow版本为1.13.1和1.15.0。

---

## mean流单元

功能

用于减去图像的均值。

输入

待处理图像

输出

减均值后的图像。

配置

各通道均值（例如mean="0.0,10.0,20.0"）

约束

适用于RGB/BGR图像

---

## meta_mapping流单元

功能

做元数据映射，对指定meta字段进行映射修改，包括meta的名称、值，值只支持基本类型。

输入

输入需要转换meta的buffer

输出

输出转换meta后的buffer

配置

src_meta="src"
dest_meta="dest"
rules="v1=v2,v3=v4,v5=v6"

约束

---

## normalize流单元

功能

图像标准化流单元

输入

待处理图像

输出

标准化处理后的图像。

配置

标准化参数（例如normalize="0.003921568627451,1,1"）

约束

适用于RGB/BGR图像

---

## output_broker流单元

功能

将算法处理结果输出到外部。

输入

算法处理结果，输出配置。

输出

算法处理结果输出到所配置的输出路径中。

配置

输出可以配置为obs、dis、webhook。可以设置重连相关参数（retry_count_limit="2", retry_interval_base_ms="100", retry_interval_increment_ms="100", retry_interval_limit_ms="200"）

约束

输出到obs\dis需在华为云开通相关服务。

---

## padding流单元

功能

图像填充流单元

输入

待处理图像

输出

填充处理后的图像。

配置

填充配置参数（例如image_width=200, image_height=100, vertical_align=top, horizontal_align=center, padding_data="0, 255, 0"）

约束

---

## resize流单元

功能

图像尺寸调整

输入

待处理图像

输出

尺寸调整后的图像。

配置

图像调整后的长度和宽度，插值方法。（例如width=128, height=128, method="inter_nearest"）

约束

---

## videodecoder流单元

功能

视频解码流单元

输入

待解码视频数据

输出

解码后的视频

配置

约束

---

## videodemuxer流单元

功能

视频解封装流单元

输入

文件流

输出

一组连续的packet流

配置

约束

---

## videoencoder流单元

功能

视频编码流单元

输入

packet流

输出

独立的图像数据

配置

约束

---

## video_input流单元

功能

获取视频输入地址

输入

URL

输出

文件流

配置

视频地址：source_url="@SOLUTION_VIDEO_DIR@/test_video_vehicle.mp4"

约束

---

## yolobox流单元

功能

从yolo模型中得到检测目标的信息，包括检测框、置信度、类别等

输入

tensor，yolo模型输出层参数，包含类别数、阈值等信息的配置文件

输出

目标检测框坐标、置信度、类别等

配置

输入输出配置：label，需设置模型输出层名称，例如layer15_conv|layer22_conv|Out_1

约束

为CPU流单元

## 流单元连接案例

1. 图片输入场景  
如果算法以图片作为输入，一般是以httpserver流单元接收图片信息。如下所示图配置，实现的功能是mnist数据集图片的推理预测功能。

```c++
    httpserver_sync_receive[type=flowunit, flowunit=httpserver_sync_receive, device=cpu, deviceid=0, request_url="http://localhost:7778", max_requests=100, time_out=10]
    mnist_preprocess[type=flowunit, flowunit=mnist_preprocess, device=cpu, deviceid=0]
    mnist_infer[type=flowunit, flowunit=mnist_infer, device=cuda, deviceid=0]
    mnist_response[type=flowunit, flowunit=mnist_response, device=cpu, deviceid=0]
    httpserver_sync_reply[type=flowunit, flowunit=httpserver_sync_reply, device=cpu, deviceid=0] 

    httpserver_sync_receive:Out_1 -> mnist_preprocess:In_1
    mnist_preprocess:Out_1 -> mnist_infer: Input
    mnist_infer: Output -> mnist_response: In_1
    mnist_response: Out_1 -> httpserver_sync_reply: In_1
```

用户在客户端，图片信息放到body体中，然后将消息发送给httpserver_sync_receive流单元，httpserver_sync_receive流单元接收请求信息，并传给下一个流单元mnist_preprocess，mnist_preprocess解析请求信息，获取图片数据，而后传给mnist_infer流单元进行模型推理，得到预测结果，最后通过httpserver_sync_reply流单元，将算法预测结果返回给用户的客户端。

1. 视频输入场景  
如果算法以视频作为输入，一般是以video_input配置视频地址，如果视频通过OBS/VIS/VCN等服务获取，一般以data_source_parser解析输入信息。
如下示例为车辆检测流程图，输入为本地视频，以video_input作为第一个流单元,配置本地视频地址，将视频数据传递给解封装流单元，再经过视频解码、图像尺寸调整、颜色空间转换、标准化、推理、获取yolo检测结果、图像画框、图像编码等一系列过程，最后通过rtsp取流，客户就可以实时观察到车辆检测结果。

```c++
    video_input[type=flowunit, flowunit=video_input, device=cpu, deviceid=0, source_url="@SOLUTION_VIDEO_DIR@/test_video_vehicle.mp4"]                                           
    videodemuxer[type=flowunit, flowunit=videodemuxer, device=cpu, deviceid=0]
    videodecoder[type=flowunit, flowunit=videodecoder, device=cpu, deviceid=0, pix_fmt=rgb, queue_size = 16, batch_size=5]
    frame_resize[type=flowunit, flowunit=cv_resize, device=cpu, deviceid=0, image_width=800, image_height=480, method="inter_nearest", batch_size=5, queue_size = 16]
    car_color_transpose[type=flowunit, flowunit=color_transpose, device=cpu, deviceid=0, batch = 5, queue_size = 16]
    car_normalize[type=flowunit, flowunit=normalize, device=cpu, deviceid=0, normalize="0.003921568627451, 0.003921568627451, 0.003921568627451", queue_size = 16, batch_size = 5]
    car_inference[type=flowunit, flowunit=car_inference, device=cuda, deviceid=0, queue_size = 16, batch_size = 5]
    car_yolobox[type=flowunit, flowunit=car_yolobox, device=cpu, deviceid=0, image_width=1920, image_height=1080, queue_size = 16, batch_size = 5]
    draw_bbox[type=flowunit, flowunit=draw_bbox, device=cpu, deviceid=0, queue_size = 16, batch_size = 5]
    videoencoder[type=flowunit, flowunit=videoencoder, device=cpu, deviceid=0, queue_size=16, default_dest_url="rtsp://localhost/test", encoder="mpeg4"]
    
    video_input:stream_meta -> videodemuxer:stream_meta
    videodemuxer:video_packet -> videodecoder:video_packet
    videodecoder:frame_info -> frame_resize:In_1
    frame_resize: Out_1 -> car_color_transpose: in_image
    car_color_transpose: out_image -> car_normalize: input
    car_normalize: output -> car_inference:data
    car_inference: "layer15-conv" -> car_yolobox: "layer15-conv"
    car_inference: "layer22-conv" -> car_yolobox: "layer22-conv"
    car_yolobox: Out_1 -> draw_bbox: In_1
    videodecoder:frame_info -> draw_bbox: In_2
    draw_bbox: Out_1 -> videoencoder: frame_info
```

如果是以data_source_parser解析视频输入，则video_input部分可替换为以下内容：

```c++
    input1[type=input]
    data_source_parser[type=flowunit, flowunit=data_source_parser, device=cpu, deviceid=0, label="<data_source_cfg> | <stream_meta>"]
```

输入信息在data_source_cfg中配置

## 视频流重连

因网络等原因导致取流推流失败时，ModelBox可以重试连接，相关参数可由用户自行设置。在data_source_parser可配置重连相关参数。

retry_enable：是否开启重连；

retry_interval：重连间隔；

retry_times:重连次数。

还可针对VIS\VCN等具体服务来配置重连参数，如vis_retry_enable，vis_retry_interval，vis_retry_times。

在output_broker输出模块，相关配置类似。如retry_count_limit="2", retry_interval_base_ms="100", retry_interval_increment_ms="100", retry_interval_limit_ms="200"。
