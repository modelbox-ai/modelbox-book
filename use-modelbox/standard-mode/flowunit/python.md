# Python开发功能单元

本章节主要介绍Python功能单元的开发流程。在开发之前，可以从[功能单元概念](../../../basic-conception/flowunit.md#功能单元)章节了解功能单元的执行过程。

## 功能单元创建

ModelBox提供了多种方式进行Python功能单元的创建：

* **通过UI创建**
  
  可参考可视化编排服务的[任务编排页面](../../../plugins/editor.md#功能单元)章节操作步骤。

* **通过命令行创建**

  ModelBox提供了模板创建工具，可以通过**ModelBox Tool**工具产生Python功能单元的模板，具体的命令为

  ```shell
  modelbox-tool template -flowunit -project-path [project_path] -name [flowunit_name] -lang python -input name=in1,device=cpu -output name=out1  
  ```

  该命令将会在`$project_path/src/flowunit`目录下创建名为`flowunit_name`的Python功能单元。

ModelBox框架在初始化时，会扫描`/path/to/flowunit/$flowunit_name`目录中的toml后缀的文件，并读取相关的信息，具体可通过**ModelBox Tool**工具查询。

创建完成的C++功能单元目录结构如下：

```shell
[flowunit-name]
     |---CMakeList.txt           # 用于CPACK 打包 
     |---[flowunit-name].toml    # 功能单元属性配置文件
     |---[flowunit-name].py      # 接口实现文件
```

## 功能单元属性配置

在开发功能单元时，应该先明确开发功能单元处理数据的类型、业务的场景。再根据需求来合理配置功能单元类型和属性。具体功能单元类型，请查看[功能单元类型](../../../basic-conception/flowunit.md#功能单元类型)章节。在确认功能单元类型后，需要对功能单元进行参数的配置。

Python功能单元典型的属性配置代码如下：

```toml
# 基础配置
[base]
name = "flowunit-name" # 功能单元名称
device = "cpu" # 功能单元运行的设备类型，Python 功能单元仅支持cpu类型。需要操作数据时，如果前面功能单元输出数据为非cpu，ModelBox框架会自动搬移至cpu
version = "1.0.0" # 功能单元组件版本号
description = "description" # 功能单元功能描述信息
entry = "python-module@ExampleFlowunit" # Python 功能单元入口函数
type = "python" # Python功能单元时，此处为固定值

# 工作模式
stream = true # 是否是Stream类型功能单元
condition  = false # 是否是条件功能单元
collapse = false # 是否是合并功能单元
expand = false # 是否是拆分功能单元

# 自定义配置项
[config]
item = value

# 输入端口描述
[input]
[input.input1] # 输入端口编号，格式为input.input[N]
name = "input" # 输入端口名称
type = "datatype" # 输入端口数据类型

# 输出端口描述
[output]
[output.output1] # 输出端口编号，格式为output.output[N]
name = "output" # 输出端口名称
type = "datatype" # 输出端口数据类型
```

## 功能单元逻辑实现

### 功能单元接口说明

功能单元提供的接口如下，开发者按需实现：

| 接口   | 功能说明          | 是否必须          | 使用说明                        |
|-|-|-|-|
| FlowUnit::open | 功能单元初始化 |  否   | 实现功能单元的初始化，资源申请，配置参数获取等|
| FlowUnit::close   | 功能单元关闭   |  否  |实现资源的释放 |
| FlowUnit::process | 功能单元数据处理 |  是 | 实现核心的数据处理逻辑|
| FlowUnit::data_pre   | 功能单元Stream流开始  |否 | 实现Stream流开始时的处理逻辑，功能单元属性 `base.stream = true` 时生效  |
| FlowUnit::data_post | 功能单元Stream流结束 |否|实现Stream流结束时的处理逻辑，功能单元数据处理类型是`base.stream = true` 时生效|

* **功能单元初始化/关闭接口**

  对应的需要实现的接口为`FlowUnit::open`, `FlowUnit::close`接口，实现样例如下：

  ```python
  import _flowunit as modelbox
  class ExampleFlowUnit(modelbox.FlowUnit):
      def open(self, config):
          # 获取流程图中功能单元配置参数值，进行功能单元的初始化
          config_item = config.get_float("key", "default_value")
          ...
          return modelbox.Status.StatusCode.STATUS_SUCCESS
      def close(self):
          # 释放功能单元的公共资源
          ...
          return modelbox.Status.StatusCode.STATUS_SUCCESS
  ```

  Open函数将在图初始化的时候调用，`config`为功能单元的配置参数，可调用相关的接口获取配置，返回`modelbox.Status.StatusCode.STATUS_SUCCESS`，表示初始化成功，否则初始化失败。

* **数据处理接口**

  对应的需要实现的接口为`FlowUnit::process`接口，其为功能单元最核心函数，输入数据的处理、输出数据的构造都在此函数中实现。接口处理流程大致如下：
  1. 通过配置的输入输出端口名，从DataContext中获取输入BufferList、输出BufferList对象
  1. 循环处理每一个输入Buffer数据，默认STREAM类型一次只处理一个数据，不必循环
  1. 将输入Buffer转换为numpy、string等常用对象，并编写业务处理逻辑。
  1. 将业务处理结果返回的结果数据调用self.create_buffer转换为Buffer
  1. 设置输出Buffer的Meta信息。
  1. 将输出Buffer放入输出BufferList中。
  1. 返回成功后，ModelBox框架将数据发送到后续的功能单元。

  实现样例如下：

  ```python
  import _flowunit as modelbox
  class ExampleFlowUnit(modelbox.FlowUnit):
      def process(self, data_ctx):
          # 获取输入输出BufferList对象，"input", "output"为对应功能单元Port名称，可以有多个。
          # 此处的"input"和"output"必须与toml的端口名称一致
          inputs = data_ctx.input("input")
          outputs = data_ctx.output("output")
          # 循环处理每一个input输入，并产生相关的输出结果，默认情况一次处理一个Buffer，则可去掉循环
          for buffer in inputs:
              # Buffer对象转为numpy对象
              np_in_data = np.array(buffer, copy= False)
              # 业务逻辑处理
              np_out_data = process_data(np_in_data)
              # numpy对象转为Buffer
              out_buffer = self.create_buffer(np_out_data)
              # 设置Buffer Meta
              out_buffer.set("key", value)
              # 将输出Buffer放入到输出Bufferlist中
              outputs.push_back(out_buffer)
          return modelbox.Status.StatusCode.STATUS_SUCCESS
  ```

  `process`的**返回值说明**如下：
  * **STATUS_SUCCESS**: 返回成功，将输出Buffer发送到后续功能单元处理。
  * **STATUS_CONTINUE**: 返回成功，暂缓发送输出Buffer的数据。
  * **STATUS_SHUTDOWN**: 停止数据处理，终止整个流程图。
  * **其他**: 停止数据处理，当前数据处理报错。

* **Stream流数据开始/结束接口**

  Stream数据流的概念介绍可参考[数据流](../../../basic-conception/stream.md)章节。对应需实现的接口为`FlowUnit::data_pre`、`FlowUnit::data_post`，此接口针对Stream类型的功能单元生效。开发者可以data_pre阶段设置Stream流级别信息存储在DataContext，在process或者data_post使用或者更新。

  使用**场景及约束**如下：
  1. `FlowUnit::data_pre`、`FlowUnit::data_post` 阶段无法操作Buffer数据，仅用于 `FlowUnit::process`中需要用到的一些资源的初始化，如解码器等  
  1. `FlowUnit::data_pre`、`FlowUnit::data_post` 不能有长耗时操作，比如文件下载、上传等，会影响并发性能

  实现样例如下：
  对应需实现的接口为`data_pre`、`data_post`，此接口Stream模式可按需实现。实现样例如下：

  ```python
  import _flowunit as modelbox
  class ExampleFlowUnit(modelbox.FlowUnit):
      def data_pre(self, data_ctx):
          # 保存Stream流级别信息。
          data_ctx.set_private_string("key", value)
          ...
          return modelbox.Status.StatusCode.STATUS_SUCCESS

      def process(self, data_ctx):
          inputs = data_ctx.input("input")
          outputs = data_ctx.output("output")
          # 获取Stream流级别信息。
          value = data_ctx.get_private_string("key")
          ...
          # 更新数据。
          value = data_ctx.set_private_string("key")
          ...
          return modelbox.Status.StatusCode.STATUS_SUCCESS

      def data_post(self, data_ctx):
          # 获取Stream流级别信息。
          value = data_context.get_private_string("key")
          ...
          return modelbox.Status.StatusCode.STATUS_SUCCESS
  ```

### Buffer操作

在实现核心数据逻辑时，需要对输入Buffer获取数据，也需要将处理结果通过输出端口往后传递。Buffer包含了Meta数据描述信息和Data数据主体两部进行操作，Buffer的详细介绍看参考基础概念的[Buffer](../../../basic-conception/buffer.md)章节。ModelBox提供了常用的Buffer接口用于实现复杂的业务逻辑。

Python的Buffer处理与C++存在差异，由于Buffer类型为ModelBox特有类型，在Python中不通用，所以Python功能单元获取输入 Buffer后需要将Data内容转换为基础类型、string、numpy等常用数据类型，再进行操作。

* **获取输入Buffer信息**

  开发者可以根据功能单元属性配置中的输入端口名称获取输入数据队列BufferList，再获取单个Buffer对象即可获取Buffer的数据和  Meta信息。 样例如下：
  
  ```python
      def process(self, data_ctx):
          input_bufs = data_ctx.input("in")
          output_bufs = data_ctx.output("out")
          for input_buf in input_bufs:
              # 获取Buffer Data数据并转化为numpy对象(输入数据为numpy类型)
              image = np.array(input_buf)
  
              # 获取Buffer Data数据并转化为string对象(输入数据为string类型)
              ss = input_buf.as_object()
  
              # 获取Buffer Meta信息
              value = input_buf.get("key")
              ...
  
          return modelbox.Status()
  ```

* **输入Buffer透传给输出端口**

  此场景是将输入Buffer直接作为输出Buffer向后传递，此时Buffer的Data、Meta等全部内容都将保留。此场景一般用于不需要实际访  问数据的功能单元，如视频流跳帧。
  
  ```python
      def process(self, data_ctx):
          input_bufs = data_ctx.input("in")
          output_bufs = data_ctx.output("out")
          for input_buf in input_bufs:
              output_bufs.push_back(input_buf)
          return modelbox.Status()
  
  ```

* **创建输出Buffer**

  业务处理完毕后处理结果一般是常用数据类型，开发者可以使用`create_buffer`接口将其转换为Buffer类型数据。

  ```python
      def process(self, data_ctx):
          input_bufs = data_ctx.input("input")
          output_bufs = data_ctx.output("output")
          for input_buf in input_bufs:
              # 若input_buf为string对象，ss即为ss
              ss = input_buf.as_object()
              ...
              #业务处理
              ss += " response"
              # 创建输出buffer，并且push给output_bufs
              out_buf = self.create_buffer(ss)
              output_bufs.push_back(out_buf)
  
          return modelbox.Status()
  ```

* **Buffer的拷贝**
  
  Python里不涉及Buffer类型拷贝，仅提供Buffer Meta的拷贝，接口为`copy_meta`， 仅拷贝Meta信息，不拷贝Data数据部分。
  
  ```python
      def process(self, data_ctx):
          buf_list = data_ctx.input("input")
          for buf in buf_list:
              ...
              infer_data = np.ones((5,5))
              new_buffer = self.create_buffer(infer_data)
              # 拷贝Buffer Meta
              status = new_buffer.copy_meta(buf)
              ...
          
          return modelbox.Status()
  ```

更多Buffer操作见[API接口](../../../api/c++.md)， Buffer的异常处理见[异常](../../../other-features/exception.md)章节。

### DataContext与SessionContext

功能单元上下文包含：`会话上下文|SessionContext`和`数据上下文|DataContext`

**DataContext 数据上下文**：DataContext是提供给当前功能单元处理数据时的临时获取BufferList
功能单元处理一次Stream流数据，或一组数据的上下文，当数据生命周期不再属于当前功能单元时，DataContext生命周期也随之结束。

  **生命周期**：功能单元内部，从流数据进入功能单元到处理完成。

  **使用场景**：获取输入、输出端口的BufferList对象；存储和获取本功能单元Stream流级别信息。

**SessionContext 会话上下文**： SessionContext主要供调用图的业务使用，业务处理数据时，设置任务基本状态对象。

  **生命周期**：多功能单元之间生效，任务级别。一次图的输入数据（ExternalData），从数据进入Flow，贯穿整个图，一直到数据处理完成结束。

  **使用场景**：保持任务级别状态信息，如任务级别参数等。

  DataContext 和 SessionContext提供了如下功能用于复杂业务的开发：

* **通过DataContext获取输入输出BufferList**

  通过输入输出端口名获取输入以及输出数据

  ```python
      def process(self, data_ctx):
          # 通过端口输入输出端口名获取BufferList，端口名分别为input, output
          input_bufs = data_ctx.input("input")
          output_bufs = data_ctx.output("output")
          ...
        
  ```

* **通过DataContext保存本功能单元Stream流级别数据**

对于Stream流的一组数据，在本功能单元内data_pre、每次process、 data_post接口内可以通过set接口设置数据来保存状态和传递信息，通过get获取数据。如data_pre和process间的数据传递，上一次process和下一次process间的数据传递。具体使用样例如下：

```python
    def data_pre(self, data_ctx):
        # 保存Stream流级别信息。
        data_ctx.set_private_string("key", value)
        ...
        return modelbox.Status.StatusCode.STATUS_SUCCESS

    def process(self, data_ctx):
        inputs = data_ctx.input("input")
        outputs = data_ctx.output("output")
        # 获取Stream流级别信息。
        value = data_ctx.get_private_string("key")
        ...
        # 更新数据。
        value = data_ctx.set_private_string("key")
        ...
        return modelbox.Status.StatusCode.STATUS_SUCCESS

    def data_post(self, data_ctx):
        # 获取Stream流级别信息。
        value = data_context.get_private_string("key")
        ...
        return modelbox.Status.StatusCode.STATUS_SUCCESS

```

* **通过DataContext获取输入输出端口Meta信息**

  除了Buffer外，开发者可以通过输入输出端口Meta传递信息，前一个功能单元设置输出Meta，后面功能单元获取输入Meta。端口的Meta信息传递不同与Buffer Meta，Buffer Meta是数据级别， 而前者是Stream流级别。

  ```python
      def process(self, data_ctx):
          // 获取输入端口Meta里的字段信息
          input_meta = data_ctx.get_input_meta("input")
          value = input_meta.get_private_string("key")
          ...  

          // 设置Meta到输出端口
          output_meta = modelbox.DataMeta()
          output_meta.set_private_string("key", value);
          res = data_ctx.set_output_meta("output", input_meta)  

          return modelbox.Status()
  ```

* **通过DataContextStream判断流异常**
  
  判断Stream流数据中处理是否存在异常，Stream流包含多个Buffer时，只要有一个Buffer存在异常即认为Stream流存在异常。
  
  ```python
      def process(self, data_ctx):
          if data_ctx.has_error():
             error = data_ctx.get_error()
             print(error.get_description(), type(error))
          ...
  
          return modelbox.Status()
  ```

* **通过DataContext发送事件**

  在开发功能单元时，存在通过功能单元自驱动的场景。如视频解码时，在输入一次视频地址数据后，后续在没有数据驱动的情况下需要反复调度解封装功能单元。 此时需要通过在功能单元中发送事件，来驱动调度器在没有数据的情况下继续调度该流单元。
  
  ```python
      def process(self, data_ctx):
          event = modelbox.FlowUnitEvent()
          data_ctx.send_event(event)
          ...
  
          return modelbox.Status()
  ```

* **通过SessionContext存储全局数据**

  存储任务的全局变量，可用于在多个功能单元之间共享数据。SessionContext的全局数据的设置和获取方式如下：
  
  ```python
  class ExampleFlowUnit1(modelbox.FlowUnit):
    def process(self, data_ctx):
            session_ctx = data_ctx.get_session_context()
            session_ctx.set_private_string("key", value)
            ...
    
            return modelbox.Status()
  ```
  
  ```python
  class ExampleFlowUnit2(modelbox.FlowUnit):
    def process(self, data_ctx):
            session_ctx = data_ctx.get_session_context()
            value = session_ctx.get_private_string("key")
            ...
            return modelbox.Status()
  ```

## 功能单元调试运行

Python功能单元无需编译，通常情况下调试阶段可以将此功能单元所在的文件夹路径配置到流程图的扫描路径`driver.dir`中，再通过**ModelBox-Tool**启动流程图运行，流程图启动时会按照配置路径扫描并加载Python功能单元。流程图的运行可参考[流程图运行](../flow-run.md)章节如果需要Python断点调试，可见[代码调试](../debug/code-debug.md)章节。
