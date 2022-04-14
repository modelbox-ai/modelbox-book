# 树莓派开发板中运行mnist

Modelbox支持当前主流的几种开发板，比如树莓派4，RK3399，RK3568芯片的Linux系统。  
本文介绍了，使用已有操作系统，如何从构建ModelBox开始，到训练生成模型，然后在进行推理的全流程。

mnist为一个REST-API服务，通过REST请求，发送base64的手写图片进行推理，REST-API给出推理结果。  
关于ModelBox中Mnist代码实现，可以先参考[第一个应用](../first-app/mnist.md)

## 编译环境准备

### 安装依赖的开发库

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

### 下载安装MindSpore-Lite推理引擎

下载aarch64的MindSporeLite：

```shell
wget https://ms-release.obs.cn-north-4.myhuaweicloud.com/1.7.0/MindSpore/lite/release/linux/aarch64/mindspore-lite-1.7.0-linux-aarch64.tar.gz
tar xf mindspore-lite-1.7.0-linux-aarch64.tar.gz
mv mindspore-lite-1.7.0-linux-aarch64 /usr/local/
ln -s /usr/local/mindspore-lite-1.7.0-linux-aarch64 /usr/local/mindspore-lite

```

其他版本下载地址： <https://www.mindspore.cn/lite>

## 编译ModelBox

1. 下载并编译ModelBox

    主站：

    ```shell
    git clone https://github.com/modelbox-ai/modelbox.git
    ```

    国内镜像：

    ```shell
    git clone https://gitee.com/modelbox/modelbox.git
    ```

1. 编译ModelBox:

    ```shell
    cd modelbox
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Debug 
    make package -j4
    ```

    如果下载慢，可以切换使用国内镜像：

    ```shell
    cmake .. -DCMAKE_BUILD_TYPE=Debug -DUSE_CN_MIRROR=yes
    ```

1. 安装ModelBox

    ```shell
    dpkg -i release/*.deb
    ```

## 使用ModelBox编排开发

1. 启动ModelBox编排开发服务

    ```shell
    modelbox-tool develop -s 
    ```

1. 链接ModelBox编排服务

    服务启动后，可以直接链接编排服务，服务启动的信息，可以通过如下命令查询：

    ```shell
    modelbox-tool develop -q
    ```

    浏览器访问上述地址的1104端口
    注意事项：
    * 如有权限问题，修改conf/modelbox.conf配置文件中的acl.allow数组，增加允许访问的IP范围。
    * 推荐使用vscode的远程链接的终端操作，vscode可以自动建立端口转发。[远程开发](https://code.visualstudio.com/docs/remote/ssh)  

1. 新建mnist服务

    * 点击任务编排
    * 点击项目->新建项目，
    * 新建项目：
        * 输入创建项目的名称:`mnist`
        * 路径: `/home/[user]`
        * 项目模板为: `mnist-mindspore`

1. 训练模型

    * 使用如下shell命令执行训练：

    ```shell
    cd ~/mnist/src/flowunit/mnist_infer
    chmod +x train.sh
    ./train.sh
    ```

1. 启动mnist服务

    浏览器打开编排界面，打开mnist项目，点击项目上`启动`按钮mnist服务。

    注意：  
    * 若启动失败，请根据界面的提示进行处理。

1. 推理验证：

    * 使用如下命令进行内置的推理验证

    ```shell
    cd ~/mnist/src/graph
    python test_mnist.py
    ```
