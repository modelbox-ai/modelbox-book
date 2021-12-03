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
  docker pull modelbox/modelbox_cuda101_develop:latest
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

## Modelbox Tool

### develop mode already enabled

在执行`modelbox-tool develop -e`开启开发者模式后，如果更改了默认位于`/usr/local/etc/modelbox/`的`modelbox.conf`配置文件的内容，需要先执行`modelbox-tool develop -d`来关闭开发者模式，再启动才行。

## 性能调试技巧

### modelbox提供性能调试工具

性能调试工具具体使用可参考[性能统计](../develop/debug/profiling.md)章节。需要说明的是，工具统计的process时间包括buffer跨设备内存拷贝时间与流单元process处理时间。首先观察的是整个图的“稀疏”程度，如果每个流单元时间线上空隙很多，且没有一个流单元是满负荷（空隙很少或几乎没有）的，则说明还未达到性能上限，需继续加大输入数据（增大QPS/增加视频路数等），直到性能无法提升后，分析图中的瓶颈点，做进一步优化。

### graph调试参数

在流程图中，如下两个参数与性能有关：

1. queue_size: 图中节点每次最大调度buffer个数；

2. batch_size：每次流单元进入process最大buffer个数；

可设置全局queue_size、batch_size，也可以在流程图的每个节点设置queue_size、batch_size。如果在两个地方同时设置，节点设置参数优先级最高。

对于Normal类型流单元，建议设置queue_size为batch_size整数倍，可简单算出并发线程数为`queue_size / batch_size`。资源允许的情况可加大并发提升性能；

### 其他注意事项

1. 减少跨设备内存拷贝；流程图中相邻流单元的输入、输出buffer的内存尽量保证在同一种设备上，这样可以减少跨设备拷贝；输入buffer内存位置可在desc中配置，输出buffer内存位置以buffer build时绑定的设备为准；

2. 避免分支不均匀连接；比如A流单元输出有左右两个分支，分支终点都为B流单元；左边分支经过流单元为1个，右边为10个，通常会导致左边分支需要等待右边分支处理完。这样A流单元会由于当前批次buffer没有及时传递出去，下一批数据无法进来导致性能浪费；
