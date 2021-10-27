# 推理功能单元

ModelBox内置了主流的推理引擎，如TensorFlow，TensorRT，Pytorch，Ascend ACL，Mindspore。在开发推理功能单元时，只需要通过配置toml文件，即可完成推理功能单元的开发。
开发之前，可以从[功能单元概念](../../framework-conception/flowunit.md)章节了解流单的执行过程。

## 推理功能单元目录结构

推理功能单元只需要提供独立的toml配置文件，指定推理功能单元的基本属性即可，目录结构为：

```shell
[flowunit-name]
     |---[flowunit-name].toml    #推理功能单元配置
     |---[model].pb              #模型文件
     |---[infer-plugin].so       #推理自定义插件
```

ModelBox框架在初始化时，会扫描[some-flowunit]目录中的toml后缀的文件，并读取相关的推理功能单元信息。\[infer-plugin\].so是推理所需插件，推理功能单元支持加载自定义插件，开发者可以实现tensorRT 自定义算子。

开发着可以通过modelbox-tool命令进行推理功能单元模板创建：
```shell
   modelbox-tool create -t infer -n FlowUnitName -d ./ProjectName/src/flowunit 
```

## 推理TOML配置

```toml
# 基础配置
[base]
name = "FlowUnit-Name" # 功能单元名称
device = "cuda" # 功能单元运行的设备类型，cpu，cuda，ascend等。
version = "1.0.0" # 功能单元组件版本号
description = "description" # 功能单元功能描述信息
entry = "model.pb" # 模型文件路径
type = "inference" #推理功能单元时，此处为固定值
virtual_type = "tensorrt" # 指定推理引擎, 可以是tensorflow, tensorrt, torch, acl, mindspore
plugin = "yolo" # 推理引擎插件

# 模型解密配置 （可选，非必须）
[encryption]
plugin_name = "modeldecrypt-plugin"   # 可以修改为自己实现的解密插件名
plugin_version = "1.0.0" # 通常情况下，rootkey和passwd需要隐藏，不能配置在此处，实现自己的解密插件，从云端下载或者隐藏在代码内
rootkey = "encrypt root key" 
passwd = "encrypt password"

# 输入端口描述
[input]
[input.input1] # 输入端口编号，格式为input.input[N]
name = "Input" # 输入端口名称
type = "datatype" # 输入端口数据类型, 取值float or uint8
device = "cpu"  #输入数据存放位置，取值cpu/cuda/ascend，tensorflow框架只支持cpu，其他场景一般和base.device一致，可不填

# 输出端口描述
[output]
[output.output1] # 输出端口编号，格式为output.output[N]
name = "Output" # 输出端口名称
type = "datatype" # 输出端口数据类型, 取值float or uint8
```

编写完成toml文件后，将对应的路径加入ModelBox的图配置中的搜索路径即可使用开发后的推理功能单元。



## 模型加解密

模型加密分为2个部分：模型加密工具和模型解密插件。

模型加密工具为`modelbox-tool key`内，使用`ModelBox Tool`加密模型后，可获取root key和模型密钥，以及加密后的模型。

ModelBox目前默认自带了模型加密功能，但为了确保模型安全，开发者应该至少实现自己的模型解密插件，至少需要隐藏模型的rootkey和passwd，具体参考修改src/drivers/devices/cpu/flowunit/model_decrypt_plugin/model_decrypt_plugin.cc内的Init函数，

```toml
  rootkey_ = config->GetString("encryption.rootkey");
  en_pass_ = config->GetString("encryption.passwd");
```

**注意事项1：**

1. `encryption.rootkey`和 `encryption.passwd`为加密后的模型解密密钥，但模型加密使用的是对称算法，模型仍然存在被破解的可能性，比如反汇编跟踪调试解密代码。。
1. 为保证模型不被非法获取，开发者需要对运行的系统环境进行加固，比如设置bootloader锁，设置OS分区签名校验，移除调试跟踪工具，若是容器的，关闭容器的ptrace功能。