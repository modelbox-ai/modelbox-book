# 容器镜像使用

AI推理业务依赖的外部组件比较多，手工安装部署工作量比较大，ModelBox提供了多种推理引擎、硬件加速卡的容器镜像方便开发者使用。本章节介绍了容器镜像使用的步骤。

## ModelBox容器镜像选择

ModelBox提供的CUDA，ASCEND硬件和tensoflow，pytorch，mindspore，tensorrt的多种镜像，开发者按照需要拉取使用。

镜像仓库：[https://hub.docker.com/u/modelbox](https://hub.docker.com/u/modelbox)

可以选择使用以下命令拉取相关的镜像。比如cuda11.2，tensorflow的open欧拉开发镜像，则镜像如下：

```shell
docker pull modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64
```

其他版本可以查看DockerHub中ModelBox仓库的镜像列表。

## 一键式脚本

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
IMAGE_NAME="modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-openeuler-x86_64"

HTTP_DOCKER_PORT_COMMAND="-p $HTTP_SERVER_PORT:$HTTP_SERVER_PORT"
docker run -itd --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
    --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name $CONTAINER_NAME -v /opt/modelbox:/opt/modelbox -v /home:/home \
    -p $SSH_MAP_PORT:22 -p $EDITOR_MAP_PORT:1104 $HTTP_DOCKER_PORT_COMMAND \
    $IMAGE_NAME
```

如果docker版本低于19.03，则需要修改脚本

```shell
docker run -itd --runtime=nvidia -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
    --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name $CONTAINER_NAME -v /opt/modelbox:/opt/modelbox -v /home:/home \
    -p $SSH_MAP_PORT:22 -p $EDITOR_MAP_PORT:1104 $HTTP_DOCKER_PORT_COMMAND \
    $IMAGE_NAME
```

注意事项：

* 可使用`vim start_docker.sh`创建文件后，`i`进入编辑模式后，粘贴上述代码，编辑修改后，`wx`保存。
* `SSH_MAP_PORT`: 为容器ssh映射端口号。
* `EDITOR_MAP_PORT`: 为可视化开发界面链接端口号。
* `HTTP_SERVER_PORT`: 为http flowunit默认服务端口号。
* `IMAGE_NAME`: 要启动的镜像名称。
* docker启动脚本中，请注意启动的镜像版本是否与自己所需的镜像版本一致。
* 如果在没有GPU的机器上执行上述命令，可以删除--gpus相关的参数。但此时只能使用CPU相关的功能单元。
* 如果启动镜像之后，端口未被占用却仍旧无法访问，需要检查防火墙。
* docker启动脚本中，请注意启动的镜像版本是否与自己所需的镜像版本一致。  

## 使用容器

容器启动完成后，需要配置容器中账号信息，并方便后续使用ssh工具链接进入容器，具体的步骤：

1. 从Host中进入容器，设置root密码

    ```shell
    docker exec -it [container id] bash
    password
    ```

1. 使用ssh，或相关的工具链接到容器内部，并启用modelbox的开发者模式。

    ```shell
    ssh [docker ip] -p [ssh map port]
    ```

    * `[docker ip]`: 容器所在得Host IP地址。
    * `[ssh map port]`：步骤1中`SSH_MAP_PORT`映射的端口号。

## gdb调试设置

如果需要在容器中进行gdb调试，需要在启动容器时添加如下选项：

```shell
--privileged
```

## docker启动脚本详解

此处以`modelbox_cuda101_develop:latest`镜像举例

```shell
docker run -itd --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video \
--tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
modelbox/modelbox_cuda101_develop:latest
```

### 参数: -itd

|     选项     | 选项简写 | 说明                                                         |
| :----------: | :------: | ------------------------------------------------------------ |
|   -detach    |    -d    | 在后台运行容器,并且打印容器id。                              |
| -interactive |    -i    | 即使没有连接，也要保持标准输入保持打开状态，一般与 -t 连用。 |
|     –tty     |    -t    | 容器重新分配一个伪输入终端，一般与 -i 连用。                 |

### 参数: -gpus all

请通过 docker -v 检查 Docker 版本。对于 19.03 之前的版本，需要使用 nvidia-docker2 和 --runtime=nvidia 标记；对于 19.03 及之后的版本，则使用 nvidia-container-toolkit 软件包和 --gpus all 标记。

### 参数: -e

设置环境变量

### -参数: -tmpfs

挂载目录到容器中，而且容器内的修改不会同步到宿主机，也不希望存储在容器内， 调用这个参数，将该挂载存储在主机的内存中，当容器停止后， tmpfs挂载被移除，即使提交容器，也不会保存tmpfs挂载

### 参数: -v

挂载宿主机的指定目录 ( 或文件 ) 到容器内的指定目录 ( 或文件 )  ro表示read-only

注意事项：

* 容器目录必须为绝对路径
* 容器销毁后，挂载的文件以及
  在容器修改过的内容仍然保留在宿主机中

### 参数: --privileged=true

当开发者需要使用gdb调试功能时，需要使用特权模式启动docker

### 参数: --cap-add=SYS_PTRACE

增加容器镜像系统的权限
ptrace()系统调用函数提供了一个进程（the “tracer”）监察和控制
另一个进程（the “tracee”）的方法。
并且可以检查和改变“tracee”进程的内存和寄存器里的数据。
它可以用来实现断点调试和系统调用跟踪。（用于gdb）

### 参数: --security-opt seccomp=unconfined

Seccomp是Secure computing mode的缩写。
设为unconfined可以允许容器执行全部的系统的调用。

有遇到无法启动的问题， 请检查是否安装nvidia-container-toolkit 和对应的cuda(10)版本
