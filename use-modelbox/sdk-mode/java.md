# Java开发方式

开发前请先准备好ModelBox开发环境，详见[环境准备](../../environment/compile.md)章节。

## Java SDK API接口说明

ModelBox提供了流程图的创建、运行、关闭等基础接口。下面是Java中使用的API列表：

| API接口  |     参数说明       |                                             函数说明                                                         |
| ------- |------------------- | ------------------------------------------------------------------------------------------------------------ |
| Flow::init | configfile: 指定config文件的路径<br /> | 初始化ModelBox服务，主要包含功能如下：<br />1. 读取driver参数，获取driver的扫描路径<br />2. 扫描指定路径下的driver文件，并创建driver实例<br />3. 加载流程图并转换为ModelBox可识别的模型<br />4. 初始化设备信息，性能跟踪和数据统计单元 |
| Flow::init | name: 指定的图的名称<br />graph: 存储图的字符串<br />format：指定图的格式 | 与上面Init的区别是，上面通过读取文件的方式，而此函数通过读取字符串的方式，其他功能相同 |
| Flow::startRun | / | 图的运行： 异步运行， 调用后直接返回， 通过调用Wait()函数判断运行是否结束 |
| Flow::waitFor | millisecond: 超时时间， 以毫秒为单位<br />ret_val: 图运行的结果 | 等待图运行结束，当图的运行时间超过millisecond表示的时间时，则强制停止图的运行，并返回TIMEOUT |
| Flow::stop() | / | 强制停止运行中的图 |
| Flow::createExternalDataMap | / | 当图中的第一个节点为input节点时， 使用此函数可以创建一个输入的ExternalDataMap， 开发者可以通过向ExternalDataMap数据中赋值并传递数据给Input节点。 |
| Flow::createStreamIO | / | 功能类似createExternalDataMap， 但更加简单易用。当图中的第一个节点为input节点时， 使用此函数可以创建一个输入的FlowStreamIO， 开发者可以通过向FlowStreamIO数据中赋值并传递数据给Input节点。 |

Java开发调用流程图时，需要先安装Java的运行包，然后再编写Java函数，调用Flow执行API执行流程图。

1. 安装Java SDK包
1. 开发流程图，配置基础部分和图部分。
1. 调用Flow::init接口，输入流程图文件。
1. 调用Flow::startRun初始化，并执行流程图。
1. 数据输入，数据处理，结果获取。
1. 调用Flow::stop释放图资源。

## 流程图配置

SDK模式的流程图的开发和标准模式基本一样，具体开发介绍见[流程图开发](../standard-mode/flow/flow.md)章节。SDK模型区别可以通过设置input和output端口作为外部数据的输入和输出。具体配置如下：

```toml
[driver]
dir=""
[graph]
graphconf = '''digraph demo {
  input1[type=input] # 定义input类型端口，端口名为input1，用于外部输入数据
  resize[type=flowunit, flowunit=resize, device=cuda]
  model_detect[type=flowunit, flowunit=model_detect, device=cuda]
  yolobox_post[type=flowunit, flowunit=yolobox_post, device=cpu]
  output1[type=output] # 定义output类型端口，端口名为output1，用于外部获取输出结果
   
  input1 -> resize:in_image
  resize:out_image -> model_detect:in
  model_detect:output -> yolobox_post:in
  yolobox_post:out -> output1
}'''
format = "graphviz"
```

如上图，input1和output1端口作为图的输入和输出，如果需要设置多个外部输入输出端口，可按照图配置规则配置多个。

## 流程图运行

* maven引入modelboxSDK包

  ```xml
    <dependency>
      <groupId>com.modelbox</groupId>
      <artifactId>modelbox</artifactId>
      <version>1.0.0</version>
    </dependency>
  ```

* **导入ModelBox包**

  编写时，需要引入头文件，并在编译时链接ModelBox库。

  ```java
  import com.modelbox.Buffer;
  import com.modelbox.Flow;
  import com.modelbox.FlowStreamIO;
  import com.modelbox.Log;
  ```

  * 图创建初始化和启动

  ```java
  public Flow CreateFlow(String file) throws ModelBoxException {
    // 创建Flow执行对象
    Flow flow = new Flow();

    // 输入流程图配置文件
    Log.info("run flow " + file);
    flow.init(file);
    // 异步执行
    flow.startRun();
    return flow;
  }
  ```

* **外部数据交互**

  发送数据到Modelbox框架处理：

  ```java
  public void Process() {
    try {
      // 创建Flow执行对象
      Flow flow = CreateFlow("path/to/graph.toml")

      // 初始化输入流对象
      FlowStreamIO streamio = flow.CreateStreamIO();

      // 发送数据到Modelbox框架
      JSONObject json_data = new JSONObject("{\"msg\":\"hello world\"}");
      Log.info("send message: " + json_data.toString());
      streamio.send("input", json_data.toString().getBytes());
      // 结束输入
      streamio.closeInput();

      // 接收处理结果
      while (true) {
        // 获取处理结果。
        Buffer outdata = streamio.recv("output", 1000 * 10);
        if (outdata == null) {
          // 处理结束，返回
          break;
        }

        // 处理出错
        if (outdata.hasError()) {
          Log.error("recv error: " + outdata.getErrorCode());
          break;
        }

        // 获取到结果
        String str = new String(outdata.getData());
        Log.info("Message is: " + str);
      }
    } catch (ModelBoxException e) {
      // 错误处理
      Log.error(e.getMessage());
    }
  ```

开发者可以根据自身业务，选择在合适的地方调用图的启动停止和数据发送。如果用户业务是多线程时，可以将flow对象可作为多线程共享对象，每个线程都往同一流程图发生数据，这样可以充分利用ModelBox的bacth并发能力。

## Java日志

默认情况，ModelBox的SDK输出日志到console，业务需要注册相关的日志处理函数，注册方法可参考[日志](../standard-mode/debug/log.md#日志sdk)章节。
