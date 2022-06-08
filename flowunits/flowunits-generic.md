# 通用类功能单元

## buff_meta_mapping

- 功能描述

提供buffer meta 字段名称和值的转换功能。

- 设备类型

cpu

- 输入端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|in_data|无限制|与功能单元设备类型一致|源数据|

- 输出端口

|端口名称|数据格式|数据存放设备类型|端口含义|
|--|--|--|--|
|out_data|无限制|与功能单元设备类型一致|转换数据|

- 配置参数

|参数名称|参数类型|是否必填|参数含义
|--|--|--|--|
|src_meta|string|是|源数据meta字段名称|
|dest_meta|string|是|转换后数据meta字段名称|
|rules|string|否|src_meta转换为dest_meta时值的替换规则, 格式为： "1=2,3=4,5=6"表示将源数据src_meta字段值如果是1，则dest_meta值修改为2，如果是3则修改为4，如果是5则修改为6。再如"abc=efg"，则表示源数据src_meta字段值如果值是"abc"则dest_meta值修改为"efg",不填则不进行值的替换，仅将字段名src_meta替换为dest_meta|

- 约束说明

无

- 使用样例

```toml
    ...
    meta_mapping[type=flowunit, flowunit=buff_meta_mapping, device=cpu, deviceid=0,  src_meta="src_name", dest_meta="dest_name", rules="abc=efg"]
    ...
    ...->meta_mapping:in_data
    meta_mapping:out_data -> ...

```
