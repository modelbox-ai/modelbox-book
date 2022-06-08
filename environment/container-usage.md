# 使用容器镜像

AI推理业务依赖的外部组件比较多，手工安装部署工作量比较大，ModelBox提供了多种推理引擎、硬件加速卡的容器镜像方便开发者使用。本章节介绍了容器镜像使用的步骤。

## 容器镜像选择

ModelBox目前提供了支持cuda，ascend加速卡硬件和TensoFlow，LibTorch，TensorRT，MindSpore，ACL等推理引擎的多种镜像，开发者可以按照需要下载使用。具体可见[容器列表](#支持容器列表)

目前Modelbox的镜像类型分为两种：开发镜像和运行镜像。

开发镜像:用于AI应用的开发和调试，镜像安装了modelbox开发库、头文件、Web UI、GDB等开发阶段所需的组件。

运行镜像：用于AI应用的打包部署。镜像只安装了AI应用运行所需的运行环境。

运行镜像比开发镜像精简稳定，通常可以在开发镜像开发完毕应用程序后打包，再安装在运行镜像，用于商用部署。

## 容器镜像下载

使用以下命令拉取相关的镜像。比如cuda11.2，tensorflow的unbuntu开发镜像，则下载最新版本镜像命令如下：

```shell
docker pull modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64:latest
```

也可以选择需要的版本号下载。

## 一键式启动脚本

为方便使用，可以使用如下一键式脚本，快速启动容器。可将如下脚本按需修改后，粘贴到ssh终端中执行：

```shell
#!/bin/bash

# ssh map port, [modify]
SSH_MAP_PORT=50022

# editor map port [modify]
EDITOR_MAP_PORT=1104

# http server port [modify]
HTTP_SERVER_PORT=8080

# container name [modify]
CONTAINER_NAME="modelbox_instance_`date +%s` "

# image name
IMAGE_NAME="modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64"

HTTP_DOCKER_PORT_COMMAND="-p $HTTP_SERVER_PORT:$HTTP_SERVER_PORT"

docker run -itd --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
    --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name $CONTAINER_NAME -v /opt/modelbox:/opt/modelbox -v /home:/home \
    -p $SSH_MAP_PORT:22 -p $EDITOR_MAP_PORT:1104 $HTTP_DOCKER_PORT_COMMAND \
    $IMAGE_NAME
```

如果docker版本低于19.03，则需要替换docker run命令为

```shell
docker run -itd --runtime=nvidia -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
    --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name $CONTAINER_NAME -v /opt/modelbox:/opt/modelbox -v /home:/home \
    -p $SSH_MAP_PORT:22 -p $EDITOR_MAP_PORT:1104 $HTTP_DOCKER_PORT_COMMAND \
    $IMAGE_NAME
```

上述脚本可支持GPU设备的挂着，如果需要使用Ascend硬件，则需要替换docker run命令为

```shell

# ascend npu card id [modify]
ASCEND_NPU_ID=0

docker run -itd --device=/dev/davinci$ASCEND_NPU_ID --device=/dev/davinci_manager \
        --device=/dev/hisi_hdc --device=/dev/devmm_svm \
        --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \  
        --name $CONTAINER_NAME -v /opt/modelbox:/opt/modelbox -v /home:/home \
        -p $SSH_MAP_PORT:22 -p $EDITOR_MAP_PORT:1104 $HTTP_DOCKER_PORT_COMMAND \
        $IMAGE_NAME
```

注意事项：

* 可使用`vim start_docker.sh`创建文件后，`i`进入编辑模式后，粘贴上述代码，编辑修改后，`wx`保存。
* `SSH_MAP_PORT`: 为容器ssh映射端口号。
* `EDITOR_MAP_PORT`: 为可视化开发界面链接端口号。
* `HTTP_SERVER_PORT`: 为http功能单元端口号。
* `IMAGE_NAME`: 要启动的镜像名称。
* `ASCEND_NPU_ID`: 需要挂载的Ascend加速卡设备号，可以通过npu-smi info 查询，一般取值为0~7。
* 如果需要在容器中进行**gdb调试**，需要在启动容器添加`--privileged`参数。
* docker启动脚本中，请注意启动的镜像版本是否与自己所需的镜像版本一致。
* 如果在没有GPU的机器上执行上述命令，可以删除--gpus相关的参数。但此时只能使用CPU相关的功能单元。
* 如果启动镜像之后，端口未被占用却仍旧无法访问，需要检查防火墙。
* docker启动脚本中，请注意启动的镜像版本是否与自己所需的镜像版本一致。  

## 使用容器

容器启动完成后，需要配置容器中账号信息，并方便后续使用ssh工具链接进入容器，具体的步骤：

1. 从Host中进入容器，设置root密码

    ```shell
    docker exec -it [container id] bash
    passwd
    ```

1. 使用ssh，或相关的工具链接到容器内部，并启用modelbox的开发者模式。

    ```shell
    ssh [docker ip] -p [ssh map port]
    ```

    * `[docker ip]`: 容器所在得Host IP地址。
    * `[ssh map port]`：步骤1中`SSH_MAP_PORT`映射的端口号。

## docker启动脚本详解

此处以`modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64:latest`镜像举例

```shell
docker run -itd --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
--tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64:latest
```

* 参数: -itd

  |     选项     | 选项简写 | 说明                                                         |
  | :----------: | :------: | ------------------------------------------------------------ |
  |   -detach    |    -d    | 在后台运行容器,并且打印容器id。                              |
  | -interactive |    -i    | 即使没有连接，也要保持标准输入保持打开状态，一般与 -t 连用。 |
  |     –tty     |    -t    | 容器重新分配一个伪输入终端，一般与 -i 连用。                 |

* 参数: -gpus

  请通过 docker -v 检查 Docker 版本。对于 19.03 之前的版本，需要使用 nvidia-docker2 和 --runtime=nvidia 标记；对于 19.03 及之后的版本，则使用 nvidia-container-toolkit 软件包和 --gpus all 标记。

* 参数：--device

  挂载设备和驱动，例如挂载0号Ascend设备和驱动：`--device=/dev/davinci0 --device=/dev/davinci_manager --device=/dev/hisi_hdc --device=/dev/devmm_svm`。

* 参数: -e

  设置环境变量

* -参数: -tmpfs

  挂载目录到容器中，而且容器内的修改不会同步到宿主机，也不希望存储在容器内， 调用这个参数，将该挂载存储在主机的内存中，当容器停止后， tmpfs挂载被移除，即使提交容器，也不会保存tmpfs挂载

* 参数: -v

  挂载宿主机的指定目录 ( 或文件 ) 到容器内的指定目录 ( 或文件 )  ro表示read-only

  注意事项：

  * 容器目录必须为绝对路径
  * 容器销毁后，挂载的文件以及
    在容器修改过的内容仍然保留在宿主机中

* 参数: --privileged=true

  当开发者需要使用gdb调试功能时，需要使用特权模式启动docker

* 参数: --cap-add=SYS_PTRACE

  增加容器镜像系统的权限
  ptrace()系统调用函数提供了一个进程（the “tracer”）监察和控制
  另一个进程（the “tracee”）的方法。
  并且可以检查和改变“tracee”进程的内存和寄存器里的数据。
  它可以用来实现断点调试和系统调用跟踪。（用于gdb）

* 参数: --security-opt seccomp=unconfined

  Seccomp是Secure computing mode的缩写。
  设为unconfined可以允许容器执行全部的系统的调用。

  有遇到无法启动的问题， 请检查是否安装nvidia-container-toolkit 和对应的cuda(10)版本

## 支持容器列表

Modelbox镜像仓库地址如下：[https://hub.docker.com/u/modelbox](https://hub.docker.com/u/modelbox)

当前支持的开发镜像列表如下：

|镜像名称|操作系统|系统架构|加速平台版本|推理引擎版本|下载地址|
|--|--|--|--|--|--|  
|modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64|ubuntu|x86_64|cuda11.2|tensorflow 2.6.0|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64/tags)|
|modelbox-develop-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64|openeuler|x86_64|cuda11.2|tensorflow 2.6.0|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64/tags)|
|modelbox-develop-libtorch_1.9.1-cuda_10.2-ubuntu-x86_64|ubuntu|x86_64|cuda10.2|libtorch 1.9.1|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-libtorch_1.9.1-cuda_10.2-ubuntu-x86_64/tags)|
|modelbox-develop-libtorch_1.9.1-cuda_10.2-openeuler-x86_64|openeuler|x86_64|cuda10.2|libtorch 1.9.1|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-libtorch_1.9.1-cuda_10.2-openeuler-x86_64/tags)|
|modelbox-develop-tensorrt_7.1.3-cuda_10.2-ubuntu-x86_64|ubuntu|x86_64|cuda10.2|tensorrt 7.1.3|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-tensorrt_7.1.3-cuda_10.2-ubuntu-x86_64/tags)|
|modelbox-develop-tensorrt_7.1.3-cuda_10.2-openeuler-x86_64|openeuler|x86_64|cuda10.2|tensorrt 7.1.3|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-tensorrt_7.1.3-cuda_10.2-openeuler-x86_64/tags)|
|modelbox-develop-mindspore_1.6.1-cann_5.0.4-ubuntu-x86_64|ubuntu|x86_64|cuda11.2|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-mindspore_1.6.1-cann_5.0.4-ubuntu-x86_64/tags)|
|modelbox-develop-mindspore_1.6.1-cann_5.0.4-openeuler-x86_64|openeuler|x86_64|cuda11.2|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-mindspore_1.6.1-cann_5.0.4-openeuler-x86_64/tags)|
|modelbox-develop-mindspore_1.6.1-cann_5.0.4-ubuntu-aarch64|ubuntu|aarch64|cann 5.0.4|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-mindspore_1.6.1-cann_5.0.4-ubuntu-aarch64/tags)|
|modelbox-develop-mindspore_1.6.1-cann_5.0.4-openeuler-aarch64|openeuler|aarch64|cann 5.0.4|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-develop-mindspore_1.6.1-cann_5.0.4-openeuler-aarch64/tags)|

各组合对应运行镜像列表如下：

|镜像名称|操作系统|系统架构|加速平台版本|推理引擎版本|下载地址|
|--|--|--|--|--|--|  
|modelbox-runtime-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64|ubuntu|x86_64|cuda11.2|tensorflow 2.6.0|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64/tags)|
|modelbox-runtime-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64|openeuler|x86_64|cuda11.2|tensorflow 2.6.0|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64/tags)|
|modelbox-runtime-libtorch_1.9.1-cuda_10.2-ubuntu-x86_64|ubuntu|x86_64|cuda10.2|libtorch 1.9.1|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-libtorch_1.9.1-cuda_10.2-ubuntu-x86_64/tags)|
|modelbox-runtime-libtorch_1.9.1-cuda_10.2-openeuler-x86_64|openeuler|x86_64|cuda10.2|libtorch 1.9.1|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-libtorch_1.9.1-cuda_10.2-openeuler-x86_64/tags)|
|modelbox-runtime-tensorrt_7.1.3-cuda_10.2-ubuntu-x86_64|ubuntu|x86_64|cuda10.2|tensorrt 7.1.3|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-tensorrt_7.1.3-cuda_10.2-ubuntu-x86_64/tags)|
|modelbox-runtime-tensorrt_7.1.3-cuda_10.2-openeuler-x86_64|openeuler|x86_64|cuda10.2|tensorrt 7.1.3|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-tensorrt_7.1.3-cuda_10.2-openeuler-x86_64/tags)|
|modelbox-runtime-mindspore_1.6.1-cann_5.0.4-ubuntu-x86_64|ubuntu|x86_64|cuda11.2|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-mindspore_1.6.1-cann_5.0.4-ubuntu-x86_64/tags)|
|modelbox-runtime-mindspore_1.6.1-cann_5.0.4-openeuler-x86_64|openeuler|x86_64|cuda11.2|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-mindspore_1.6.1-cann_5.0.4-openeuler-x86_64/tags)|
|modelbox-runtime-mindspore_1.6.1-cann_5.0.4-ubuntu-aarch64|ubuntu|aarch64|cann 5.0.4|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-mindspore_1.6.1-cann_5.0.4-ubuntu-aarch64/tags)|
|modelbox-runtime-mindspore_1.6.1-cann_5.0.4-openeuler-aarch64|openeuler|aarch64|cann 5.0.4|mindspore 1.6.1、ACL|[下载链接](https://hub.docker.com/r/modelbox/modelbox-runtime-mindspore_1.6.1-cann_5.0.4-openeuler-aarch64/tags)|
