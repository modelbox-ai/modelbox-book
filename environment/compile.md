# 源码编译安装

ModelBox框架采用C++语言编写，工程编译软件是CMake，本章节主要讲解ModelBox源代码的手动编译安装过程。

基于ModelBox开发AI应用，推荐使用[容器镜像](./container-usage.md)方式开发，避免从源代码构建ModelBox耗时。源码编译安装方式主要用于不支持Docker的系统，如部分端侧、嵌入式设备等。

## 一键式脚本

如果只是运行mnist验证，可以使用如下一键式脚本准备编译环境。脚本：[get-start.sh](get-start.sh)

```shell
curl https://modelbox-ai.com/modelbox-book/environment/get-start.sh | sh /dev/stdin -m -j2
```

参数说明：
  * `-m`： 从国内镜像下载依赖软件包。
  * `-j[n]`： 并发编译数量。默认是2个。

## 编译依赖准备

在编译ModelBox之前，需要安装依赖软件，ModelBox依赖软件要求如下:

| 类别   | 依赖       | 依赖说明           | 最低版本                | 推荐版本     | 是否必须 | 相关组件                              |
| ------ | ---------- | ------------------ | ----------------------- | ------------ | -------- | ------------------------------------- |
| 编译器 | gcc        | gcc编译器          | 4.8                     | 7.x          | 是       | 所有                                  |
| 编译器 | g++        | g++编译器          | 4.8                     | 7.x          | 是       | 所有                                  |
| 编译器 | CMake      | CMake工具          | 2.9                     | 3.5          | 是       | 所有                                  |
| OS     | Linux      | Linux操作系统      | ubuntu16.04, centOS 7.2 | ubuntu 18.04 | 是       | 所有                                  |
| 运行时 | nodejs     | 前端编译           | 10.x                    | V12.x        | 否       | 前端Editor                            |
| 运行时 | python     | Python编译         | 3.x                     | 3.8          | 否       | Python支持                            |
| 开发库 | cuda       | cuda支持           | 10.1                    | 10.2         | 否       | cuda支持                              |
| 开发库 | cann     | Ascend支持         |   5.0.4                 |   5.0.4           | 否       | Ascend支持                            |
| 开发库 | ffmpeg     | 视频解码编码支持   |                         |              | 否       | 视频相关功能                          |
| 开发库 | tensorrt   | TensorRT模型推理   |                         |              | 否       | TensorRT相关的模型推理功能            |
| 开发库 | tensorflow | TensorFlow推理支持 |                         |              | 否       | TensorFlow相关的模型推理功能          |
| 开发库 | libtorch | LibTorch推理支持 |                         |              | 否       | LibTorch相关的模型推理功能          |
| 开发库 | mindspore | MindSpore推理支持 |                         |              | 否       | MindSpore相关的模型推理功能          |
| 开发库 | httplib    | HTTP服务支持       |                         |              | 是       | modelbox-server相关的功能组件 |
| 开发库 | cpprest    | HTTP服务支持       |                         |              | 否       | HTTP相关功能单元 |

上述依赖可按需求选择，其中 **是否必须** 为 **是** 的依赖，必须要安装到编译环境中才能正常编译代码。如果使用基于镜像的开发环境，可以省去依赖库的安装, 具体见[容器镜像](./container-usage.md)章节。

如果不使用容器镜像，也可按上述依赖列表自行基于当前操作系统进行安装。ubuntu操作系统基础软件安装命令如下：

```shell
apt-get update
apt-get -y install cmake git wget build-essential npm curl \
   python3 python3-pip python-is-python3 \
   libssl-dev libcpprest-dev libopencv-dev libgraphviz-dev python3-dev \
   libavfilter-dev libavdevice-dev libavcodec-dev
pip install requests opencv-python
```

如上述依赖安装比较慢，可以使用国内的镜像进行安装，具体镜像如下：

* pip镜像下载：

    配置参考：  

    <https://mirrors.tuna.tsinghua.edu.cn/help/pypi/>  

    临时使用参考：

    ```shell
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple requests opencv-python
    ```

* apt镜像下载：

    配置参考：  

    <https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/>  
    <https://mirrors.tuna.tsinghua.edu.cn/help/debian/>

* npm镜像：

    配置参考：  

    ```shell
    npm config set registry https://registry.npmmirror.com
    ```

如果需要使用模型推理，还需要安装对应推理引擎、CUDA或CANN等相关依赖。

## 编译ModelBox

1. 准备

    编译ModelBox之前，需要准备好开发环境。或在镜像中进行编译，或按上述依赖列表，安装相应的依赖组件。

1. 下载ModelBox代码

    **github**：

    ```shell
    git clone https://github.com/modelbox-ai/modelbox.git
    ```

    **gitee**：

    ```shell
    git clone https://gitee.com/modelbox/modelbox.git
    ```

1. 编译ModelBox

    ```shell
    mkdir build
    cd build
    cmake ..
    ```

    * `-DUSE_CN_MIRROR=yes`：在编译过程中，还需要下载第三方依赖，请保持网络能正常连接第三方服务器，如在国内无法下载，可以增加此cmake参数，从国内镜像下载依赖。  
    * `-DLOCAL_PACKAGE_PATH`：若本地已经有依赖的第三方软件包，则可以使用此参数指定本地依赖包路径，若使用ModelBox编译镜像时，编译镜像的`/opt/thirdparty/source`已经有相关依赖包，可直接指定本地路径使用，若需要从公共源码仓下载，则无需指定此参数，但需要确保网络通畅。
    * `-WITH_WEBUI=off`：可视化WEBUI会增加一些额外依赖下载，如果不需要可增加此参数关闭。
    * `-DWITH_ALL_DEMO=off`：是否编译全量的样例，如果不需要可以关闭。
    * 如需编译release版本，可以执行如下cmake命令

    ```shell
    cmake -DCMAKE_BUILD_TYPE=Release ..
    ```
  
    * 如需进行断点调试，则应编译debug版本，可以执行如下cmake命令

    ```shell
    cmake -DCMAKE_BUILD_TYPE=Debug ..
    ```

1. 编译安装包

    ```shell
    make package -j16
    ```

    编译完成后，将在`release`目录下生成对应的安装包。

## 安装ModelBox

ModelBox编译完成后，将生成配套OS安装的安装包，如deb、rpm包和tar.gz包，路径为编译目录的`release`子目录。可根据使用需求进行安装，下表是软件包的用途对照表。

### 安装包功能对照表

| 类型     | 名称                                                             | 说明                                    |
| -------- | ---------------------------------------------------------------- | --------------------------------------- |
| 运行库   | modelbox-x.x.x-Linux-libmodelbox.[deb&#124;rpm]                  | ModelBox核心运行库。                    |
| 运行库   | modelbox-x.x.x-Linux-graph-graphviz.[deb&#124;rpm]               | 图解析组件。                            |
| 服务组件 | modelbox-x.x.x-Linux-server.[deb&#124;rpm]                       | ModelBox Server服务组件。               |
| 运行库   | modelbox-x.x.x-Linux-ascend-device-flowunit.[deb&#124;rpm]       | Ascend设备SDK以及配套基础功能单元组件。 |
| 运行库   | modelbox-x.x.x-Linux-cpu-device-flowunit.[deb&#124;rpm]          | CUDA设备SDK以及配套基础功能单元组件。   |
| 运行库   | modelbox-x.x.x-Linux-cuda-device-flowunit.[deb&#124;rpm]         | CPU设备SDK以及配套基础功能单元组件。    |
| 开发库   | modelbox-x.x.x-Linux-libmodelbox-devel.[deb&#124;rpm]            | ModelBox开发库。                        |
| 开发库   | modelbox-x.x.x-Linux-server-devel.[deb&#124;rpm]                 | ModelBox Server服务插件开发库。         |
| 开发库   | modelbox-x.x.x-Linux-ascend-device-flowunit-devel.[deb&#124;rpm] | Ascend设备开发库。                      |
| 开发库   | modelbox-x.x.x-Linux-cpu-device-flowunit-devel.[deb&#124;rpm]    | CPU开发包。                             |
| 开发库   | modelbox-x.x.x-Linux-cuda-device-flowunit-devel.[deb&#124;rpm]   | CUDA设备开发库。                        |
| 手册   | modelbox-x.x.x-Linux-document.deb.[deb&#124;rpm]   | 开发手册，包含API说明。                        |
| WebUI   | modelbox-x.x.x-Linux-modelbox-webui.[deb&#124;rpm]   | 编排界面。                        |
| 运行库   | modelbox-x.x.x-py3-none-any.whl                                  | python wheel包。                        |
| 全量包   | modelbox-x.x.x-Linux.tar.gz                                      | 全量安装包，包括上述所有组件。          |

安装包说明

* ModelBox运行库，CPU运行库，graphviz图解析组件必须安装。
* Ascend设备组件，CUDA设备组件，可根据硬件配置情况合理安装。
* modelbox-server服务组件，推荐安装。
* modelbox-x.x.x-py3-none-any.whl在需要Python运行时安装。
* modelbox-x.x.x-Linux.tar.gz可解压直接使用。推荐使用安装包，方便管理。

### 安装命令说明

1. debian安装包

    ```shell
    sudo dpkg -i *.deb
    ```

1. rpm安装包

    ```shell
    sudo rpm -i *.rpm
    ```

1. Python wheel包

    ```shell
    pip install *.whl
    ```

1. tar.gz包的使用。（可选，如果已经安装了deb|rpm包，则可不用安装tar.gz包）

    ```shell
    tar xf modelbox-x.x.x-Linux.tar.gz
    ```

    将解压后的目录，复制到`/`目录，此步骤可选。

    ```shell
    cd modelbox
    cp * / -avf
    ```

    若未选择上述步骤，未复制modelbox文件到`/`目录，则需要将`/lib/systemd/system/modelbox.service`中文件修改为对应的解压目录

    ```shell
    ExecStart=[path/to]/modelbox -p /var/run/modelbox.pid -c [path/to]/modelbox.conf
    ```

    将上述路径[[path/to]修改为对应解压后的路径。然后执行如下命令

    ```shell
    cp modelbox.service /lib/systemd/system/modelbox.service
    systemctl daemon-reload
    ```

## 启动服务

如安装了`modelbox-x.x.x-Linux-server`，可以使用下述命令启动服务

```shell
systemctl enable modelbox
systemctl start modelbox
```

关于ModelBox Server服务的配置，请查阅[运行服务](../use-modelbox/standard-mode/deployment/server.md)章节
