# 推理功能单元

ModelBox内置了主流的推理引擎，如TensorFlow，TensorRT，Ascend ACL。在开发推理功能单元时，只需要通过配置toml文件，即可完成推理功能单元的开发。

样例工程可从源代码目录的`example/inference/flowunit/`中获取。开发之前，可以从[功能单元概念](../../framework-conception/flowunit.md)章节了解流单的执行过程。

## 推理功能单元目录结构

推理功能单元只需要提供独立的toml配置文件，指定推理功能单元的基本属性即可，其目录结构为：

```shell
[some-flowunit]
     |---[some-flowunit].toml
     |---[model].pb
     |---[plugin].so
```

ModelBox框架在初始化时，会扫描/path/to/flowunit/[some-flowunit]目录中的toml后缀的文件，并读取相关的推理功能单元信息，具体可通过`modelbox-tool`工具查询是否配置正确。\[plugin\].so是推理所需插件，可按需实现。

## TOML配置

```toml
# 基础配置
[base]
name = "FlowUnit-Name" # 功能单元名称
device = "Device" # 功能单元运行的设备类型，cpu，cuda，ascend等。
version = "x.x.x" # 功能单元组件版本号
description = "description" # 功能单元功能描述信息
entry = "model.pb" # 模型文件路径
type = "inference" #推理功能单元时，此处为固定值
virtual_type = "tensorrt" # 指定推理引擎, 可以是tensorflow, tensorrt, atc
plugin = "yolo" # 推理引擎插件

# 输入端口描述
[input]
[input.input1] # 输入端口编号，格式为input.input[N]
name = "Input" # 输入端口名称
type = "datatype" # 输入端口数据类型

# 输出端口描述
[output]
[output.output1] # 输出端口编号，格式为output.output[N]
name = "Output" # 输出端口名称
type = "datatype" # 输出端口数据类型
```

编写完成toml文件后，将对应的路径加入ModelBox的搜索路径即可使用开发后的推理功能单元。
