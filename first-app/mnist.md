# Mnist

MNIST案例是使用MNIST数据集，训练的一个手写数字识别TensorFlow模型，搭建的一个简易的HTTP请求服务。

## 功能

将MNIST数据，通过base64格式发送到ModelBox推理，并获取结果。

流程上：启动HTTP Server监听端口接收HTTP请求，然后从请求体中的image_base64解析出图片，接着用训练出的MNIST模型进行推理预测，最后将识别出的数字返回给用户。

Request 请求样例：

``` json
{
    "image_base64": "xxxxx"
}
```

Response 响应样例：

``` json
{
    "predict_reuslt": "x"
}
```

## 模型准备

AI应用开发前需要准备好匹配当前ModelBox版本支持的推理框架和版本的模型文件，这里默认已经准备好了TensorFlow 2.6.0版本的minist pb模型文件。模型训练可参考[TensorFlow教程](https://doc.codingdict.com/tensorflow/tfdoc/tutorials/mnist_beginners.html)。

## AI应用开发

首先准备开发环境，备好了之后进入应用开发环节，主要分为流程图编排、功能单元编写、运行与调试、打包部署4个开发步骤。

### 环境准备

环境准备可以使用现成ModelBox镜像，也可以从源代码构建ModelBox。本章节使用现成ModelBox镜像开发，如果没有相关的镜像，可以参考[树莓派开发板Mnist](../cases/mnist-on-sbc.md)。

使用镜像开发，省去了准备复杂编译环境的大量工作，推荐ModelBox开发者直接使用镜像开发，ModelBox镜像相关的指导，可以先参考[容器使用](../environment/container-usage.md)章节。

1. 安装启动Docker后，执行下列命令下载Docker镜像。由于训练的是TensorFlow的模型（支持CPU和GPU推理），所以这里拉取对应TensorFlow版本镜像。

    ```shell
    docker pull modelbox/modelbox-develop-tensorflow_2.6.0-cuda_11.2-ubuntu-x86_64:latest
    ```

1. 配置并启动容器

    可采用一键式脚本快速进入容器。参考[一键式启动脚本](../environment/container-usage.md)相关内容。

### 项目创建与运行

1. 进入容器并且切换至ModelBox开发者模式

    ```shell
    modelbox-tool develop -s
    ```

   注意事项：
    * 如果需要通过可视化UI进行图的编排，可参考[可视化编排服务](../plugins/editor.md)章节访问`http://[host]:[EDITOR_MAP_PORT]/editor/`地址；
    * 如果访问被拒绝，可参考[运行编排服务](../plugins/editor.md)中的[访问控制列表](../plugins/editor.md#编排插件配置)相关内容。

1. 连接ModelBox编排服务

    服务启动后，可直接连接编排服务，服务启动信息可通过如下命令查询：

    ```shell
    modelbox-tool develop -q
    ```

    浏览器访问上述地址的1104端口，注意事项：
    * 如有权限问题，修改conf/modelbox.conf配置文件中的acl.allow数组，增加允许访问的IP范围。
    * 推荐使用vscode的远程连接的终端操作，vscode可以自动建立端口转发。[远程开发](https://code.visualstudio.com/docs/remote/ssh)

1. 创建项目工程

    * 点击任务编排
    * 点击项目->新建项目，
    * 新建项目：
      * 输入创建项目的名称:`mnist`
      * 路径: `/home/[user]`
      * 项目模板为: `mnist`

    创建出的文件夹说明如下所示：

    ```tree
    ├─CMake：CMake目录，存放一些自定义CMake函数
    ├─package：CPack打包配置目录，目前支持tgz、rpm、deb三种格式
    ├─src：源代码目录，开发的功能单元、流程图、服务插件（可选）都存放在这个目录下
    │  ├─flowunit：功能单元目录
    │  │  ├─mnist_preprocess：预处理功能单元
    │  │  ├─mnist_infer：tensorflow推理功能单元
    │  │  ├─mnist_response：HTTP响应构造功能单元
    │  ├─graph：流程图目录
    │  └─service-plugin：服务插件目录
    ├─test：单元测试目录，使用的是Gtest框架
    └─thirdparty：第三方库目录
    │    └─CMake：预制的下载第三方库cmake文件
    |---CMakeLists.txt  CMake编译文件
    ```

1. 运行流程图

    在**任务编排**页面中打开流程图，点击绿色**运行按钮**可运行流程图；

1. 测试

    * 脚本测试

      可以使用已经准备好测试脚本`[project_root]/src/graph/test_mnist.py`，直接运行`python3 test_mnist.py`会下载测试图片并进行HTTP测试验证。

    * UI界面测试

      在**任务管理**页面中点击**调试**可进行api调试，选择Mnist模板，将测试图片进行base64编码后放入请求body中，再点击send按钮可进行测试；

### 流程图说明

流程图编排是根据实际情况将现有业务逻辑拆分为N个功能单元，再将功能单元串联成一个完整的业务的过程。功能单元分为ModelBox预置功能单元和自定义功能单元，当预置功能单元满足不了业务场景时，需要开发者进行功能单元开发。有两种方式可编排流程图，第一种是使用UI进行可视化UI编排，第二种是直接编写图文件。具体可参考[流程图开发章节](../use-modelbox/standard-mode/flow/flow.md#流程图开发)。这里采用第二种方式。

![mnist-flowchart alt rect_w_300](../assets/images/figure/solution/mnist-flowchart.png)

如上图所示，根据业务流程可以将业务划分为5个功能单元，分别为接收HTTP请求，MNIST预处理，MNIST模型推理，MNIST响应构造，发送HTTP响应。对应图编排文件描述如下

``` toml
[graph]
format = "graphviz"
graphconf = '''digraph mnist_sample {
    node [shape=Mrecord]
    httpserver_sync_receive[type=flowunit, flowunit=httpserver_sync_receive, device=cpu, time_out_ms=5000, endpoint="http://0.0.0.0:8190", max_requests=100]
    mnist_preprocess[type=flowunit, flowunit=mnist_preprocess, device=cpu]
    mnist_infer[type=flowunit, flowunit=mnist_infer, device=cpu, deviceid=0, batch_size=1]
    mnist_response[type=flowunit, flowunit=mnist_response, device=cpu]
    httpserver_sync_reply[type=flowunit, flowunit=httpserver_sync_reply, device=cpu]

    httpserver_sync_receive:out_request_info -> mnist_preprocess:in_data
    mnist_preprocess:out_data -> mnist_infer:Input
    mnist_infer:Output -> mnist_response:in_data
    mnist_response:out_data -> httpserver_sync_reply:in_reply_info
}
```

除了构建图之外，还需要增加必要配置，如功能单元扫描路径，日志级别等，具体可参考样例文件`[project_root]/src/graph/mnist.toml`。

### 功能单元说明

ModelBox提供基础预置功能单元，除此之外还需补充流程图中缺失的功能单元，具体开发可参考[功能单元开发章节](../use-modelbox/standard-mode/flowunit/flowunit.md#功能单元开发)。

这里接收HTTP请求、发送HTTP响应两个功能单元ModelBox已提供，我们只需实现MNIST的预处理，推理，响应构造三个功能单元即可。

下面将详细说明这三个功能单元：

* MNIST预处理功能单元
  
  预处理需要做：解析出图片，对图片进行reshape，构建功能单元输出Buffer。
  
  ``` python
  # 获取输入输出端口BufferList
  in_data = data_context.input("In_1")
  out_data = data_context.output("Out_1")
  
  for buffer in in_data:
      # 从Buffer中获取请求body
      request_body = json.loads(buffer.as_object().strip(chr(0)))
            
      if request_body.get("image_base64"):
          img_base64 = request_body["image_base64"]
          img_file = base64.b64decode(img_base64)
          # 将图片进行resize
          img = cv2.imdecode(np.fromstring(img_file, np.uint8), cv2.IMREAD_GRAYSCALE)
          img = cv2.resize(img, (28, 28))
          infer_data = np.array([255 - img], dtype=np.float32)
          infer_data = np.reshape(infer_data, (784,)) / 255.
          
          # 构建输出Buffer
          add_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
          out_data.push_back(add_buffer)
      else:
          # 获取字段错误处理
          error_msg = "wrong key of request_body"
          modelbox.error(error_msg)
          add_buffer = modelbox.Buffer(self.get_bind_device(), "")
          add_buffer.set_error("MnistPreprocess.BadRequest", error_msg)
          out_data.push_back(add_buffer)
  ```

  详细代码可参考`[project_root]/src/flowunit/mnist_preprocess`。

* MNIST推理功能单元
  
  ModelBox已经适配了TensorFlow推理引擎，支持CPU和GPU推理，只需推理功能单元只需准备好模型和对应的配置文件即可。
  
  配置文件如下：

  ```toml
  [base]
  name = "mnist_infer"  # 功能单元名称
  device = "cpu"        # 功能单元设备类型
  version = "1.0.0"     # 功能单元版本号
  description = "Recognition handwritten digits recognition."  # 功能单元版本号
  entry = "./mnist_model.pb"   # 模型路径
  type = "inference"           # 功能单元类型
  virtual_type = "tensorflow"  # 推理引擎
  
  [input]
  [input.input1] 
  name = "Input"        # 模型输入端口名称
  type = "float"        # 模型输入端口设备类型
  
  [output]
  [output.output1] 
  name = "Output"       # 模型输出端口名称
  type = "float"        # 模型输出端口数据类型
  ```

  详细代码可参考`[project_root]/src/flowunit/mnist_infer`。

* MNIST响应功能单元
  
  得到推理的结果之后，需要构造响应：
  
  ``` python
  # 获取输入输出端口BufferList
  in_data = data_context.input("in_data")
  out_data = data_context.output("out_data")
  
  for buffer in in_data:
      # 从Buffer中获取推理结果
      result_str = ''
      if buffer.has_error():
          error_msg = buffer.get_error_msg()
          result = {
              "error_msg": str(error_msg)
          }
      else:
          max_index = np.argmax(buffer.as_object())
          result = {
              "predict_result": str(max_index)
          }
      
      # 构建输出Buffer
      result_str = (json.dumps(result) + chr(0)).encode('utf-8').strip()
      add_buffer = modelbox.Buffer(self.get_bind_device(), result_str)
      # 将输出Buffer放入对应的输出端口BufferList中
      out_data.push_back(add_buffer)
  ```

  详细代码可参考`[project_root]/src/flowunit/mnist_response`。
