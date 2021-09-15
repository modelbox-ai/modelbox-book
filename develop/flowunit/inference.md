# 推理流单元

ModelBox内置了主流的推理引擎，如TensorFlow，TensorRT，Ascend ACL。在开发推理流单元时，只需要通过配置toml文件，即可完成推理流单元的开发。

样例工程可从源代码目录的`example/inference/flowunit/`中获取。开发之前，可以从[流单元概念](../../framework-conception/flowunit.md)章节了解流单的执行过程。

## 推理流单元目录结构

推理流单元只需要提供独立的toml配置文件，指定推理流单元的基本属性即可，其目录结构为：

```shell
[some-flowunit]
     |---[some-flowunit].toml
     |---[model].pb
     |---[plugin].so
```

ModelBox框架在初始化时，会扫描/path/to/flowunit/[some-flowunit]目录中的toml后缀的文件，并读取相关的推理流单元信息，具体可通过**ModelBox Tool**工具查询是否配置正确。\[plugin\].so是推理所需插件，可按需实现。

## 模型加解密

模型加密分为2个部分：模型加密工具和模型解密插件。

模型加密工具为`modelbox-tool key`内，使用`ModelBox Tool`加密模型后，可获取root key和模型密钥，以及加密后的模型。

modelbox目前默认自带了模型加密功能，但为了确保模型安全，开发者应该至少实现自己的模型解密插件，至少需要隐藏模型的rootkey和passwd，具体参考修改src/drivers/devices/cpu/flowunit/model_decrypt_plugin/model_decrypt_plugin.cc内的Init函数，

```toml
  rootkey_ = config->GetString("encryption.rootkey");
  en_pass_ = config->GetString("encryption.passwd");
```

**注意事项1：**

1. `encryption.rootkey`和 `encryption.passwd`为加密后的模型解密密钥，但模型加密使用的是对称算法，模型仍然存在被破解的可能性，比如反汇编跟踪调试解密代码。。
1. 为保证模型不被非法获取，开发者需要对运行的系统环境进行加固，比如设置bootloader锁，设置OS分区签名校验，移除调试跟踪工具，若是容器的，关闭容器的ptrace功能。

TOML配置

```toml
# 基础配置
[base]
name = "FlowUnit-Name" # 流单元名称
device = "Device" # 流单元运行的设备类型，cpu，cuda，ascend等。
version = "x.x.x" # 流单元组件版本号
description = "description" # 流单元功能描述信息
entry = "model.pb" # 模型文件路径
type = "inference" #推理流单元时，此处为固定值
virtual_type = "tensorrt" # 指定推理引擎, 可以是tensorflow, tensorrt, atc
plugin = "yolo" # 推理引擎插件

# 模型解密配置 （可选，非必须）
[encryption]
plugin_name = "modeldecrypt-plugin"   # 可以修改为自己实现的解密插件名
plugin_version = "1.0.0"
# 通常情况下，rootkey和passwd需要隐藏，不能配置在此处，实现自己的揭秘插件，从云端下载或者隐藏在代码内
rootkey = "encrypt root key"
passwd = "encrypt password"

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

编写完成toml文件后，将对应的路径加入ModelBox的搜索路径即可使用开发后的推理流单元。
