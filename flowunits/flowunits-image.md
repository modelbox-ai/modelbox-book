# 图像操作类功能单元

## resize

### 功能描述

对图片进行缩放操作。

### 设备类型

cpu、cuda、ascend

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|image_width|uint32_t|是|缩放后的图片宽|
|image_height|uint32_t|是|缩放后的图片高|
|interpolation|uint32_t|否|插值方法，不同硬件取值范围不同。<br/> cpu场景："inter_nearest"、"inter_linear"、"inter_cubic"、"inter_area"、"inter_lanczos4"、"inter_max"、"warp_fill_outliers"、"warp_inverse_map", 默认值为"inter_nearest"<br/> cuda场景："inter_nn"、"inter_linear"、"inter_cubic"、"inter_super"、"inter_lanczos"， 默认值为"inter_nn" <br/> ascend场景："default"、"bilinear_opencv"、"nearest_neighbor_opencv"、"bilinear_tensorflow"、"nearest_neighbor_tensorflow"，默认值为"default"|

### 约束说明

1. 由于底层实现差异，不同硬件支持插值方式不同。
1. ascend硬件当前只支持输入图片格式为"nv12"

### 使用样例

无

## padding

### 功能描述

对图片进行缩放操作。

### 设备类型

cpu、cuda、ascend

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|image_width|uint32_t|是|填充后的图片宽|
|image_height|uint32_t|是|填充后的图片高|
|vertical_align|string|否|纵向的对齐方式，取值范围："top"、"center"、"bottom",默认为"top"|
|horizontal_align|string|否|横向的对齐方式，取值范围："left"、"center"、"right",默认为"left"|
|padding_data|string|否|填充的像素值，格式："255,255,0"， 参数顺序和数据维度对应。默认为"0,0,0"|
|need_scale|bool|否|是否需要改变大小，默认为ture|
|interpolation|uint32_t|否|插值方法，不同硬件取值范围不同。<br/> cpu场景："inter_nearest"、"inter_linear"、"inter_cubic"、"inter_area"、"inter_lanczos4"、"inter_max"、"warp_fill_outliers"、"warp_inverse_map", 默认值为"inter_nearest"<br/> cuda场景："inter_nn"、"inter_linear"、"inter_cubic"、"inter_super"、"inter_lanczos"， 默认值为"inter_nn" <br/> ascend场景："default"、"bilinear_opencv"、"nearest_neighbor_opencv"、"bilinear_tensorflow"、"nearest_neighbor_tensorflow"，默认值为"default"|

### 约束说明

1. 由于底层实现差异，不同硬件支持插值方式不同。
1. ascend硬件当前只支持输入图片格式为"nv12"

### 使用样例

无

## crop

### 功能描述

对图片进行缩放操作。

### 设备类型

cpu、cuda、ascend

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|
|in_region|[矩形框数据类型](./flowunits.md#矩形框数据类型)|cpu|裁剪区域|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

无

### 约束说明

1. ascend硬件当前只支持输入图片格式为"nv12"

### 使用样例

无

## normalize

### 功能描述

对数据进行归一化。

### 设备类型

cpu、cuda

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_data|[Tensor数据类型](./flowunits.md#tensor数据类型)|与功能单元设备类型一致|源数据|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_data|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果后数据,输出buffer数据类型为ModelBoxDataType::MODELBOX_FLOAT|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|standard_deviation_inverse|string|是|归一化参数, 参数格式："0.003921568627451,0.003921568627451,0.003921568627451" ，0.00392156862745为1/255， 参数顺序和数据维度对应 |

### 约束说明

无

### 使用样例

无

## mean

### 功能描述

对数据进行减均值操作。

### 设备类型

cpu、cuda

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_data|[Tensor数据类型](./flowunits.md#tensor数据类型)|与功能单元设备类型一致|源数据|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_data|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果后数据, 输出buffer数据类型为ModelBoxDataType::MODELBOX_FLOAT|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|mean|string|是|减均值参数, 参数格式："124.5, 116.5, 104.5" ，参数顺序和数据维度对应 |

### 约束说明

无

### 使用样例

无

## color_convert

### 功能描述

对图片进行颜色通道转换。

### 设备类型

cuda

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|out_pix_fmt|string|是|转换后的通道格式，取值范围："bgr", "rgb", "gray"|

### 约束说明

支持场景："rgb" 转 "bgr"、"bgr" 转 "rgb"、 "rgb" 转 "gray"、 "bgr" 转 "gray"、 "gray" 转 "bgr"、 "gray" 转 "rgb"

### 使用样例

无

## image_rotate

### 功能描述

对图片进行旋转。

### 设备类型

cpu、cuda

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|rotate_angle|int_32|否|按顺时针旋转角度，取值范围：90, 180, 270。 如果不填该参数时，默认根据输入buffer meta携带的"rotate_angle"字段旋转。可用于视频解码携带"rotate"信息的场景|

### 约束说明

无

### 使用样例

无

## image_decoder

### 功能描述

对图片解码。

### 设备类型

cpu、cuda

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_encoded_image|vector<u_char>|待解码图片的二进制数据

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|pix_fmt|string|是|解码后的通道格式，取值范围："bgr", "rgb", "nv12"。cuda场景不支持"nv12"|

### 约束说明

1. cuda场景图片解码格式只支持"bgr", "rgb"，不支持"nv12"。

### 使用样例

无

## image_preprocess

### 功能描述

对图片做预处理：包含减均值、归一化、通道转换 。

### 设备类型

cuda

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_data|[Tensor数据类型](./flowunits.md#tensor数据类型)|与功能单元设备类型一致| ,输出buffer数据类型为ModelBoxDataType::MODELBOX_FLOAT|

### 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|output_layout|string|是|输出数据的布局类型，取值范围："hwc", "chw"|
|mean|string|是|减均值参数, 参数格式："124.5, 116.5, 104.5" ，参数顺序和数据维度对应|
|standard_deviation_inverse|string|是|归一化参数, 参数格式："0.003921568627451,0.003921568627451,0.003921568627451" ，0.00392156862745为1/255， 参数顺序和数据维度对应 |

### 约束说明

1. 输入图片布局仅支持hwc

### 使用样例

无

## draw_bbox

### 功能描述

在图片上画框, 一般用于yolo物体检测结果在原图上的显示。

### 设备类型

cpu

### 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|源图片信息|
|in_region|vector<[检测矩形框类型](./flowunits.md#yolo检测矩形框类型)>|cpu|待画框区域列表|

### 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_image|[图片数据类型](./flowunits.md#图片数据类型)|与功能单元设备类型一致|结果图片信息|

### 配置参数

无

### 约束说明

无

### 使用样例

无
