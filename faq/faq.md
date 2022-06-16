# FAQ

## ModelBox

### 什么是ModelBox，ModelBox有什么功能？

ModelBox是一个AI应用的推理框架，ModelBox通过编排和插件化的形式支持AI应用的开发，支持的数据有视频，音频，语音，文本，通用数据的编排处理，ModelBox的主要功能列表可参考[这里](../README.md#ModelBox主要功能)

### 相比直接调用底层API开发AI业务，ModelBox有什么优势？

ModelBox主要聚焦解决AI应用开发的问题，相比直接调用底层API，开发者需要关注每个底层的API使用方法，关注并发，关注GPU，NPU设备编程接口，关注TensorRT，TensorRT等推理框架的编程API，与云计算结合的接口，和分布式通信，日志等琐碎而复杂的周边代码。  

ModelBox解决的就是业务开发的周边问题，将周边问题交由ModelBox处理，ModelBox通过对内存，CPU，GPU，周边组件的精细化管理，使AI推理业务开发更高效，性能也更高，质量也更好。

### ModelBox目前支持哪些框架训练的模型（TensorFlow、Caffe、LibTorch、MindSpore等）

ModelBox框架里面包含了支持TensorFlow, Caffe, LibTorch、MindSpore模型运行所需的功能单元Flowunit，我们称为推理功能单元(Inference Flowunit)，这些推理功能单元可以直接加载对应的模型文件，而不需要编写代码，只需提供一个简单的配置文件，即可将模型引入到ModelBox的流程中。目前支持的模型有TensorFlow, TensorRT, Ascend ACL模型。

## ModelBox组件

### ModelBox程序包含哪些部分

ModelBox目前包含如下组件

1. 微服务ModelBox Server
1. 运行库ModelBox Library
1. 维护工具ModelBox Tool
1. CPU相关的功能单元
1. Huawei Ascend相关的功能单元
1. CUDA相关的功能单元
1. 可视化编辑工具

### ModelBox支持服务式吗？

ModelBox有专门的微服务程序，ModelBox Server，ModelBox Server内置了通用的管理插件，和基本功能，开发者只需要配置ModelBox Server即可启动微服务。

### 如何调试ModelBox程序

ModelBox本身为C++代码编写，开发者可以通过如下方式调试ModelBox程序和相关的功能单元：

1. GDB，IDE等工具调试
1. ModelBox运行日志。
1. ModelBox Profiling性能统计工具。

具体操作方法，可参考[调试定位](../use-modelbox/standard-mode/debug/debug.md)章节内容

## 模型问题

### TensorRT在解析模型出错

当TensorRT在解析模型出错时，如果报错 " expecting compute x.x got compute 7.5, please rebuild"，说明模型和推理引擎不配套，需要转换模型到配套的硬件, 并在与当前环境配置相同的环境上重新编译模型。

### 查看当前的镜像对应的欧拉系统的版本

```shell
cat /etc/EulerLinux.conf
```

## 开发常见问题

### 流单元找不到

常见日志报错：`code: Not Found, errmsg: create flowunit 'xxx' failed.`, 通常有如下几个原因，可一一进行排查：

1. 流程图toml配置的driver路径不包含所需流单元so或文件夹；
1. 流单元编译异常，找不到符号。通常会在日志前面扫描到so时提示错误，可通过ldd、c++filt命令进行具体定位；

### 端口未连接

常见日志报错：`code: Bad config, errmsg: flowunit 'xxxx' config error, port not connect correctly`, 可能错误原因：代码中流单元定义的端口，未在toml图中使用。需检查定义输入输出端口名称、或driver路径是否错误。

### 创建图失败

常见日志报错：`code: Invalid argument, errmsg: check stream fail.`, `build flow failed`等, 通常有以下几种可能错误：

1. toml流程图中，node定义节点在后面边连接中未使用；
1. 端口冲突，如多个输出连接到同一输入端口（if-else终点除外）；
1. if-else流单元之后的各分支，最终需要合并到一个端口上；
1. if-else分支中不能使用stream类型流单元；
1. 多个if-else流单元不能共用同一个终点；
1. 流单元端口连接不能跨越if-else，拆分合并流单元；

具体约束原因详见[stream流](../basic-conception/stream.md)章节。
