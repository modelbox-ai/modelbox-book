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
modelbox-tool template -flowunit -lang infer -name [name]  
```

## 推理功能流单元配置(toml格式)

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
plugin = "infer-plugin.so" # 推理自定义引擎插件 仅支持virtual_type为tensorflow, tensorrt

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

### 说明

+ 模型文件类型和模型推理引擎一一对应，如下表： 

|推理引擎|模型格式|
|---|---|
|tensorflow| xxx.pb|
|tensorrt | xxx.engine(序列化模型)|
|torch| xxx.pt|
|acl| xxx.om|
|mindspore| xxx.mindir|

+ 模型引擎为tensorrt时，可以对应三种模型格式，toml文件的修改如下：

模型类型为uff, 配置文件当中增加

```toml
   ...
   [config]
   uff_input = "input.1.28.28" # 输入名称以及输入的shape大小，以.隔开
   ...
```

模型类型为caffe, 配置文件当中修改增加

```toml
   ...
   entry = "xxx.prototxt"
   model_file = "xxx.caffemodel"
   ...
```

模型类型为onnx, 配置文件当中修改 ``` entry = "xxx.onnx" ```

模型类型为tensorrt自己生成的序列化模型, 不论任何后缀直接配置到entry即可

+ base域下面的plugin选项

plugin即为文件路径下面的so，该so为为自定义modelbox的tensorflow推理的预处理以及后处理函数，需要自定义实现以下接口(为可选项)

```c++
   // tensorflow
   class InferencePlugin {
      ...
      /**
        * @brief init plugin
        * @param config modelbox config, can get key value from the graph toml
        * @return init result, modelbox status
        */
      virtual modelbox::Status PluginInit(std::shared_ptr<modelbox::Configuration> config) = 0;
      
      /**
        * @brief before inferencere, preprocess data
        * @param ctx modelbox datacontext, can get input data from this
        * @param input_tf_tensor_list tensorflow TF_Tensor*, after preprocess data from ctx, 
        *        build input TF_Tensor to inference
        * @return preprocess result, modelbox status
        */
      virtual modelbox::Status PreProcess(std::shared_ptr<modelbox::DataContext> ctx, std::vector<TF_Tensor *> &input_tf_tensor_list) = 0;

      /**
        * @brief after inferencere, postprocess data
        * @param ctx modelbox datacontext, can get modelbox output object from this
        * @param output_tf_tensor_list tensorflow TF_Tensor*, after inference output data store in it, 
        *        build output bufferlist from it
        * @return postprocess result, modelbox status
        */
      virtual modelbox::Status PostProcess(std::shared_ptr<modelbox::DataContext> ctx, std::vector<TF_Tensor *> &output_tf_tensor_list) = 0;
      ...
  };
```

+ tensorrt的自定义算子构建的PluginFactory

目前自带yolo版本的PluginFactory，只需要在toml配置文件当中增加

```toml
   [config]
   plugin = "yolo"
```

后续支持自定义算子的tensorrt插件，编译成动态库，把路径配置在这里

+ torch模型需要保存成成jit模型，参考sample如下：

```python
   jit_model = torch.jit.script(Module)
   jit_model.save("save_model.pt")
```

+ torch模型的输入输出配置可以自定义名称，在此仅仅为位置占位符，但是需要保证输入输出的顺序一致

## 模型加解密

模型加密分为2个部分：模型加密工具和模型解密插件。

模型加密工具为`modelbox-tool key`内，使用`ModelBox Tool`加密模型后，可获取root key和模型密钥，以及加密后的模型。

ModelBox目前默认自带了模型加密功能，但为了确保模型安全，开发者应该至少实现自己的模型解密插件，至少需要隐藏模型的rootkey和passwd，具体参考修改src/drivers/devices/cpu/flowunit/model_decrypt_plugin/model_decrypt_plugin.cc内的Init函数，

```toml
  rootkey_ = config->GetString("encryption.rootkey");
  en_pass_ = config->GetString("encryption.passwd");
```

**注意事项1：**

1. `encryption.rootkey`和 `encryption.passwd`为加密后的模型解密密钥，但模型加密使用的是对称算法，模型仍然存在被破解的可能性，比如反汇编跟踪调试解密代码。
1. 为保证模型不被非法获取，开发者需要对运行的系统环境进行加固，比如设置bootloader锁，设置OS分区签名校验，移除调试跟踪工具，若是容器的，关闭容器的ptrace功能。
