# FAQ

## ModelBox

### 什么是ModelBox，ModelBox有什么功能？

ModelBox是一个AI应用的推理框架，ModelBox通过编排和插件化的形式支持AI应用的开发，支持的数据有视频，音频，语音，文本，通用数据的编排处理，ModelBox的主要功能列表可参考[这里](../README.md#ModelBox主要功能)

### 相比直接调用底层API开发AI业务，ModelBox有什么优势？

ModelBox主要聚焦解决AI应用开发的问题，相比直接调用底层API，开发者需要关注每个底层的API使用方法，关注并发，关注GPU，NPU设备编程接口，关注tensorflow，tensorrt等推理框架的编程API，与云计算结合的接口，和分布式通信，日志等琐碎而复杂的周边代码。  

ModelBox解决的就是业务开发的周边问题，将周边问题交由ModelBox处理，ModelBox通过对内存，CPU，GPU，周边组件的精细化管理，使AI推理业务开发更高效，性能也更高，质量也更好。

### ModelBox目前支持哪些框架训练的模型（TensorFlow、Caffe、PyTorch等）

ModelBox框架里面包含了支持TensorFlow, Caffe, Pytorch模型运行所需的功能单元Flowunit，我们称为推理功能单元(Inference Flowunit)，这些推理功能单元可以直接加载对应的模型文件，而不需要编写代码，只需提供一个简单的配置文件，即可将模型引入到ModelBox的流程中。目前支持的模型有TensorFlow, TensorRT, Ascend ACL模型。

## ModelBox组件

### ModelBox程序包含哪些部分

ModelBox目前包含如下组件

1. 微服务ModelBox Server
1. 运行库ModelBox Library
1. 维护工具ModelBox Tool
1. CPU相关的功能单元
1. Huawei Ascend相关的功能单元
1. Cuda相关的功能单元
1. 可视化编辑工具

### ModelBox支持服务式吗？

ModelBox有专门的微服务程序，ModelBox Server，ModelBox Server内置了通用的管理插件，和基本功能，开发者只需要配置ModelBox Server即可启动微服务。

### 如何调试ModelBox程序

ModelBox本身为C++代码编写，开发者可以通过如下方式调试ModelBox程序和相关的功能单元：

1. GDB，IDE等工具调试
1. ModelBox运行日志。
1. ModelBox Profiling性能统计工具。

具体操作方法，可参考[调试定位](../develop/debug/debug.md)章节内容

## 模型问题

### tensorrt在解析模型出错

当tensorrt在解析模型出错时，如果报错 " expecting compute x.x got compute 7.5, please rebuild"，说明模型和推理引擎不配套，需要转换模型到配套的硬件, 并在与当前环境配置相同的环境上重新编译模型。

## 运行环境

### 其他版本的cuda

  如果想要下载其他cuda版本的镜像，可以选择使用以下命令。比如cuda10.1版本镜像，就是`modelbox_cuda101_develop`。其他版本均可以此类推。

  ```shell
  docker pull modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64
  ```

  docker启动脚本中，请注意启动的镜像版本是否与自己所需的镜像版本一致。

### docker启动脚本详解

此处以`modelbox_cuda101_develop:latest`镜像举例

```shell
docker run -itd --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
--tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
modelbox/modelbox_cuda101_develop:latest
```

#### -itd

|     选项     | 选项简写 | 说明                                                         |
| :----------: | :------: | ------------------------------------------------------------ |
|   -detach    |    -d    | 在后台运行容器,并且打印容器id。                              |
| -interactive |    -i    | 即使没有连接，也要保持标准输入保持打开状态，一般与 -t 连用。 |
|     –tty     |    -t    | 容器重新分配一个伪输入终端，一般与 -i 连用。                 |

#### -gpus all

请通过 docker -v 检查 Docker 版本。对于 19.03 之前的版本，需要使用 nvidia-docker2 和 --runtime=nvidia 标记；对于 19.03 及之后的版本，则使用 nvidia-container-toolkit 软件包和 --gpus all 标记。

#### -e

设置环境变量

#### --tmpfs

挂载目录到容器中，而且容器内的修改不会同步到宿主机，也不希望存储在容器内， 调用这个参数，将该挂载存储在主机的内存中，当容器停止后， tmpfs挂载被移除，即使提交容器，也不会保存tmpfs挂载

#### -v

挂载宿主机的指定目录 ( 或文件 ) 到容器内的指定目录 ( 或文件 )  ro表示read-only

注意事项：

* 容器目录必须为绝对路径
* 容器销毁后，挂载的文件以及
  在容器修改过的内容仍然保留在宿主机中

#### --privileged=true

当开发者需要使用gdb调试功能时，需要使用特权模式启动docker

#### --cap-add=SYS_PTRACE

增加容器镜像系统的权限
ptrace()系统调用函数提供了一个进程（the “tracer”）监察和控制
另一个进程（the “tracee”）的方法。
并且可以检查和改变“tracee”进程的内存和寄存器里的数据。
它可以用来实现断点调试和系统调用跟踪。（用于gdb）

#### --security-opt seccomp=unconfined

Seccomp是Secure computing mode的缩写。
设为unconfined可以允许容器执行全部的系统的调用。

有遇到无法启动的问题， 请检查是否安装nvidia-container-toolkit 和对应的cuda(10)版本

### 查看当前的镜像对应的欧拉系统的版本

```shell
cat /etc/EulerLinux.conf
```

## 功能单元

### 功能单元的分类

功能单元可以分为两大类

#### 1. 实际的功能单元

由实际代码所实现，每套代码对应自己的功能单元

#### 2. 虚拟功能单元

只有一个in配置文件，所有的具体实现在一个tensorrt的模块中，端口名、数据类型都是通过配置文件配置的。

其中的plugin参数指定了可以注册功能的类，比如plugin为yolo，也就是说，yolo的实例注册到tensorrt里面的。

### sessioncontext与datacontext

sessioncontext保存的是当前flow的全局变量，每一个flowunit存储在里面的数据在其他flowunit也可以读到。

datacontext表示当前flowunit在当前流的数据buffer，可以设置输入输出，也可以保存私有数据。

### video_input

video_input的repeat可以创建多个并发视频，并不是串行视频流

## ModelBox Tool

### develop mode already enabled

在执行`modelbox-tool develop -e`开启开发者模式后，如果更改了默认位于`/usr/local/etc/modelbox/`的`modelbox.conf`配置文件的内容，需要先执行`modelbox-tool develop -d`来关闭开发者模式，再启动才行。

## 开发常见问题

### 流单元找不到

常见日志报错：`code: Not Found, errmsg: create flowunit 'xxx' failed.`, 通常有如下几个原因，可一一进行排查：

1. 流程图toml配置的driver路径不包含所需流单元so或文件夹；
1. 流单元编译异常，找不到符号。通常会在日志前面扫描到so时提示错误，可通过ldd、c++filt命令进行具体定位；

### 端口未连接

常见日志报错：`code: Bad config, errmsg: flowunit 'xxxx' config error, port not connect correctly`, 可能错误原因：代码中流单元定义的端口，未在toml图中使用。需检查定义输入输出端口名称、或driver路径是否错误。

### 创建图失败

常见日志报错：`code: Invalid argument, errmsg: check stream fail.`, `build flow failed`等, 通常有以下几种可能错误：

1. toml流程图中，node定义节点在后面边链接中未使用；
1. 端口冲突，如多个输出连接到同一输入端口（if-else终点除外）；
1. if-else流单元之后的各分支，最终需要合并到一个端口上；
1. if-else分支中不能使用stream类型流单元；
1. 多个if-else流单元不能共用同一个终点；
1. 流单元端口连接不能跨越if-else，拆分合并流单元；

具体约束原因详见[stream流](../framework-conception/stream.md)章节。
