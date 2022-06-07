# Python开发功能单元

Python开发功能单元时，需要预先安装ModelBox的运行包， 可参考[编译安装章节](../../compile/compile.md#安装命令说明)，
在开发之前，可以从[功能单元概念](../../../basic-conception/flowunit.md)章节了解流单的执行过程。

## 功能单元创建

Modelbox提供了多种方式进行Python功能单元的创建:

* 通过UI创建
  
  xxx

* 通过命令行创建

ModelBox提供了模板创建工具，可以通过**ModelBox Tool**工具产生python功能单元的模板，具体的命令为

```shell
modelbox-tool template -flowunit -lang python -name [name]  
```

ModelBox框架在初始化时，会扫描/path/to/flowunit/[FlowUnitName]目录中的toml后缀的文件，并读取相关的信息，具体可通过**ModelBox Tool**工具查询。

创建完成的C++功能单元目录结构如下：

```shell
[flowunit-name]
     |---CMakeList.txt           # 用于CPACK 打包 
     |---[flowunit-name].toml    # 功能单元属性配置文件
     |---[flowunit-name].py      # 接口实现文件
```

## 功能单元属性配置

在开发功能单元时，应该先明确开发功能单元处理数据的类型，业务的场景。再根据需求来合理配置功能单元类型和属性。具体功能单元类型，请查看[功能单元类型](../../../basic-conception/flowunit.md##功能单元类型)章节。在确认功能单元类型后，需要对功能单元进行参数的配置。

Python功能单元典型的属性配置代码如下：

```toml
# 基础配置
[base]
name = "FlowUnit-Name" # 功能单元名称
device = "cpu" # 功能单元运行的设备类型，python 功能单元仅支持cpu类型。
version = "x.x.x" # 功能单元组件版本号
description = "description" # 功能单元功能描述信息
entry = "python-module@SomeFlowunit" # python 功能单元入口函数
type = "python" # Python功能单元时，此处为固定值

# 工作模式
stream = true # 是否数据功能单元
condition  = false # 是否条件功能单元
collapse = false # 是否合并功能单元
expand = false # 是否拆分功能单元

# 默认配置值
[config]
item = value

# 输入端口描述
[input]
[input.input1] # 输入端口编号，格式为input.input[N]
name = "Input" # 输入端口名称
type = "datatype" # 输入端口数据类型

# 输出端口描述
[output]
[output.output1] # 输出端口编号，格式为output.output[N]
name = "Output" # 输出端口名称
type = "datatype" # 输出端口数据类型
```

## 功能单元逻辑实现

### 功能单元接口说明

功能单元提供的接口如下，开发着需要按照需求实现：

| 接口   | 说明          | 是否必须          | 使用说明                        |
|-|-|-|-|
| FlowUnit::Open | 功能单元初始化 |  否   | 实现功能单元的初始化，资源申请，配置参数获取等|
| FlowUnit::Close   | 功能单元关闭   |  否  |实现资源的释放 |
| FlowUnit::Process | 功能单元数据处理 |  是 | 实现核心的数据处理逻辑|
| FlowUnit::DataPre   | 功能单元Stream流开始  |否 | 实现Stream流开始时的处理逻辑，功能单元属性 `base.stream = true` 时生效  |
| FlowUnit::DataPost | 功能单元Stream流结束 |否|实现Stream流结束时的处理逻辑，功能单元数据处理类型是`base.stream = true` 时生效|

* 功能单元初始化/关闭接口

对应的需要实现的接口为`open`, `close`接口，实现样例如下：

```python
import _flowunit as modelbox

class SomeFlowunit(modelbox.FlowUnit):
    def open(self, config):
        # 获取流程图中功能单元配置参数值
        config_item = config.get_float("config", "default")

        # 初始化公共资源。
        # 返回初始化结果。
        return modelbox.Status.StatusCode.STATUS_SUCCESS

    def close(self):
        # 关闭功能单元，返回关闭结果。
        return modelbox.Status.StatusCode.STATUS_SUCCESS
```

Open函数将在图初始化的时候调用，`config`为功能单元的配置参数，可调用相关的接口获取配置，返回`modelbox.Status.StatusCode.STATUS_SUCCESS`，表示初始化成功，否则初始化失败。

* 数据处理接口

对应的需要实现的接口为`process`接口，实现样例如下：

```python
import _flowunit as modelbox

class SomeFlowunit(modelbox.FlowUnit):
    def process(self, data_ctx):
        # 获取输入，输出控制对象。
        # 此处的"Input"和"Output"必须与toml的端口名称一致
        inputs = data_ctx.input("Input")
        outputs = data_ctx.output("Output")

        # 循环处理每一个input输入
        for buffer in inputs:
            np_in_data = np.array(buffer, copy= False)
            np_out_data = process_data(np_in_data)
            out_buffer = self.create_buffer(np_out_data)
            out_buffer.set("brightness", self.__brightness)
            outputs.push_back(out_buffer)

        return modelbox.Status.StatusCode.STATUS_SUCCESS
```

* Process接口处理流程大致如下：
    1. 从context中获取Input输入，Output输出对象，参数为Port名称。
    1. 循环处理每一个inputs数据。
    1. 将input数据转换为numpy对象，并编写process_data函数。
    1. 将process_data结果返回的output numpy数据调用self.create_buffer，转换为buffer。
    1. 设置output buffer的meta信息。
    1. 将output放入outputs结果集中。
    1. 返回处理结果。
* Process的返回值说明

| 返回值          | 说明                                                 |
| --------------- | ---------------------------------------------------- |
| STATUS_OK       | 返回成功，将Output中的数据，发送到后续FlowUnit流程。 |
| STATUS_CONTINUE | 返回成功，暂缓发送Output中的数据。                   |
| STATUS_SHUTDOWN | 停止数据处理，终止整个流程图。                       |
| 其他            | 停止数据处理，当前数据处理报错。                     |

* Stream流数据开始/结束接口

Stream数据流的概念介绍可参考[数据流](../../../basic-conception/stream.md)章节。对应需实现的接口为`FlowUnit::DataPre`、`FlowUnit::DataPost`，此接口针对Stream类型的功能单元生效。使用场景及约束如下：

1. `FlowUnit::DataPre`、`FlowUnit::DataPost` 阶段无法操作数据，仅用于 `FlowUnit::Process`中需要用到的一些资源的初始化，如解码器等  
1. `FlowUnit::DataPre`、`FlowUnit::DataPost` 不能有长耗时操作，比如文件下载、上传等，会影响并发性能

典型场景如，处理一个视频流时，在视频流开始时会调用`FlowUnit::DataPre`，视频流结束时会调用`FlowUnit::DataPost`。FlowUnit可以在DataPre阶段初始化解码器，在DataPost阶段关闭解码器，解码器的相关句柄可以设置到DataContext上下文中。DataPre、DataPost接口处理流程大致如下：

1. Stream流数据开始时，在DataPre中获取数据流元数据信息，并初始化相关的上下文，存储DataContext->SetPrivate中。
1. 处理Stream流数据时，在Process中，使用DataContext->GetPrivate获取到上下文对象，并从Input中获取输入，处理后，输出到Output中。
1. Stream流数据结束时，在DataPost中释放相关的上下文信息。

实现样例如下：
对应需实现的接口为`data_pre`、`data_post`，此接口Stream模式可按需实现。实现样例如下：

```python
import _flowunit as modelbox

class SomeFlowunit(modelbox.FlowUnit):
    def data_pre(self, data_ctx):
        # 获取Stream流元数据信息
        stream_meta = data_ctx.get_input_meta("Stream-Meta")

        # 初始化Stream流数据处理上下文对象。
        decoder = self.CreateDecoder(stream_meta)

        # 保存流数据处理上下文对象。
        data_ctx.SetPrivate("Decoder", decoder)
        return modelbox.Status.StatusCode.STATUS_SUCCESS

    def process(self, data_ctx):
        # 获取流数据处理上下文对象。
        decoder = data_ctx.GetPrivate("Decoder")
        inputs = data_ctx.input("Input")
        outputs = data_ctx.output("Output")

        # 处理输入数据。
        decoder.Decode(inputs, outputs)
        return modelbox.Status.StatusCode.STATUS_SUCCESS

    def data_post(self, data_ctx):
        # 关闭解码器。
        decoder = data_context.GetPrivate("Decoder")
        decoder.DestroyDecoder()
        return modelbox.Status.StatusCode.STATUS_SUCCESS
```

### Buffer操作

在实现核心数据逻辑时，需要对输入Buffer获取数据，也需要将处理结果通过输出端口往后传递。Buffer包含了BufferMeta数据描述信息和DeviceData数据主体两部进行操作，Buffer的详细介绍看参考基础概念的[Buffer](../../../basic-conception/buffer.md)章节。modelbox提供了常用的Buffer接口用于实现复杂的业务逻辑。

* 获取功能单元输入Buffer信息

根据功能单元属性配置中的输入端口名称获取输入数据队列BufferList，再获取每个Buffer对象即可获取Buffer的各种属性信息：数据指针、数据大小、BufferMeta字段等等。 此外BufferList也提供了快速获取数据指针的接口，样例如下：

```python
    
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("in")
        output_bufs = data_ctx.output("out")
        for input_buf in input_bufs:
            # 获取Buffer的Device Data数据并转化为numpy对象(输入数据为numpy类型)
            image = np.array(input_buf)

            # 获取Buffer的Device Data数据并转化为string对象(输入数据为string类型)
            ss = input_buf.as_object()

            # 获取Buffer Meta信息
            height = input_buf.get("height")
            ...


        return modelbox.Status()
```

* 输入Buffer透传给输出端口

此场景是将输入Buffer直接作为输出Buffer向后传递，此时Buffer的数据、BufferMeta等全部属性都将保留。此场景一般用于不需要实际访问数据的功能单元，如视频流跳帧。

```python

    def Process(self, data_ctx):
        input_bufs = data_ctx.input("in")
        output_bufs = data_ctx.output("out")
        for input_buf in input_bufs:
            output_bufs.push_back(input_buf)
        return modelbox.Status()

```

* 创建新的输出Buffer

数据处理完成后，需要创建输出Buffer并把结果数据填充进Buffer，设置Buffer Meta。Modelbox提供多种方式创建Buffer：

BufferList::Build : 一次创建多个指定大小的Buffer, Buffer类型与当前功能单元硬件类型一致。Buffer数据内容需要单独填充。

BufferList::BuildFromHost : 一次创建多个指定大小的Buffer，Buffer类型为cpu类型，Buffer数据在创建时写入，一次调用完成创建和赋值。

BufferList::EmplaceBack ： 调用时隐式创建Buffer，Buffer类型与当前功能单元硬件类型一致。Buffer数据在调用时写入。一次调用完成创建和赋值，较BufferList::Build相比简单。

BufferList::EmplaceBackFromHost ： 调用时隐式创建Buffer，Buffer类型为cpu类型。Buffer数据在调用时写入。

```python

    # string
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("input")
        output_bufs = data_ctx.output("output")
        for input_buf in input_bufs:
            # 若input_buf为string对象，ss即为ss
            ss = input_buf.as_object()
            ...
            ss += " response"
            # 创建输出buffer，并且push给output_bufs
            out_buf = self.create_buffer(ss)
            output_bufs.push_back(out_buf)

        return modelbox.Status()
```
约束：

* Buffer的拷贝

Python的Buffer处理与C++存在差异，由于Buffer类型为Modelbox特有类型，在Python中不通用，所以Python功能单元获取输入Buffer后需要将DeviceData数据转换为基础类型、string、numpy等常用数据类型，再进行操作。操作完成后创建输出Buffer
拷贝BufferMeta：接口为copy_meta， 仅拷贝BufferMeta信息，不拷贝DeviceData数据部分。

实际

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            infer_data = np.ones((5,5))
            new_buffer = self.create_buffer(infer_data)
            buf1 = buf
            status = new_buffer.copy_meta(buf)
            ...
        
        return modelbox.Status()
```


更多Buffer操作见[API接口](../../../api/c++.md)， Buffer的异常处理见[异常](../../../other-features/exception.md)章节。


### DataContext与SessionContext

功能单元上下文包含：`会话上下文|SessionContext`和`数据上下文|DataContext`

* DataContext 数据上下文

DataContext是提供给当前功能单元处理数据时的临时获取BufferList
功能单元处理一次Stream流数据，或一组数据的上下文，当数据生命周期不再属于当前功能单元时，DataContext生命周期也随之结束。

生命周期: 绑定BufferList，从数据进入FlowUnit到处理完成。

使用场景: 通过DataContext->Input接口获取输入端口BufferList，通过DataContext->Output接口获取输出端口BufferList对象,通过DataContext->SetPrivate接口设置临时对象，DataContext->GetPrivate接口获取临时对象。

* SessionContext 会话上下文

SessionContext主要供调用图的业务使用，业务处理数据时，设置状态对象。

生命周期: 绑定ExternalData，从数据进入Flow，贯穿整个图，一直到数据处理完成结束。

使用场景: 例如http服务同步响应场景，首先接收到http请求后转化成buffer数据，然后通过ExternalData->GetSessionContext接口获取到SessionContext，接着调用SessionContext->SetPrivate设置响应的回调函数，之后通过ExternalData->Send接口把buffer数据发送到flow中；经过中间的业务处理功能单元；最后http响应功能单元中在业务数据处理完成后，再调用SessionContext->GetPrivate获取响应回调函数，发送http响应。至此SessionContext也结束。

DataContext 和 SessionContext提供了如下功能用于复杂业务的开发：

* 获取输入以及输出buffer

通过Input， Output接口获取输入以及输出数据

```python
    Status ExampleFlowUnit::Process(std::shared_ptr<DataContext> data_ctx) {
        // 该flowunit为1输入1输出，端口号名字分别为input, output
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
    }
```

* 通过DataContext保存本功能单元Stream流级别数据。
对于Stream流的一组数据，在本功能单元内DataPre、每次Process、 DataPost接口内可以通过SetPrivate接口设置数据来保存状态和传递信息，通过GetPrivate获取数据。如DataPre和Process间的数据传递，上一次Process和下一次Process间的数据传递。具体使用样例如下：

```python
    modelbox::Status VideoDecoderFlowUnit::DataPre(
    std::shared_ptr<modelbox::DataContext> data_ctx) {

        data_ctx.set_private_string("test", "test")
        ...
        return modelbox.Status()
        }

    modelbox::Status VideoDecoderFlowUnit::Process(
        std::shared_ptr<modelbox::DataContext> ctx) {
        ss = data_ctx.get_private_string("test")
        ...
        return modelbox.Status()
    }

    modelbox::Status VideoDecoderFlowUnit::DataPost(
        std::shared_ptr<modelbox::DataContext> data_ctx) {
        ss = data_ctx.get_private_string("test")
        ...
        return modelbox.Status()
    }
```

* 获取输入端口的Meta和设置输出端口的Meta

```python
    def Process(self, data_ctx):
        input_meta = data_ctx.get_input_meta("input")
        res = data_ctx.set_output_meta("output", input_meta)
        ...

        return modelbox.Status()
```

* 通过DataContext判断是否存在error

```python
    def Process(self, data_ctx):
        if data_ctx.has_error():
           error = data_ctx.get_error()
           print(error.get_description(), type(error))
        ...

        return modelbox.Status()
```

* 通过DataContext发送event

在写自定义流单元当中，存在通过单数据驱动一次，process继续自驱动的场景，此时需要通过在流单元东中发送event继续驱动调度器在没有数据的情况下调度该流单元

```python
    def Process(self, data_ctx):
        event = modelbox.FlowUnitEvent()
        data_ctx.send_event(event)
        ...

        return modelbox.Status()
```

* 通过SessionContext存储全局数据

存储任务的全局变量，可用于在多个功能单元之间共享数据。SessionContext的全局数据的设置和获取方式如下：

```python
def Process(self, data_ctx):
        session_ctx = data_ctx.get_session_context()
        session_ctx.set_private_string("test", "test")
        ...

        return modelbox.Status()
```

```python
def Process(self, data_ctx):
        session_ctx = data_ctx.get_session_context()
        print(session_ctx.get_private_int("test"))
        ...
        return modelbox.Status()
```

## 功能单元调试运行

Python功能单元无需编译，通常情况下调试阶段可以将此功能单元所在的文件夹路径配置到流程图的扫描路径driver.dir中，再通过Modelbox-Tool 启动流程图运行，流程图启动时会扫描并加载Python功能单元。如果需要Python断点调试，可见[代码调试](../debug/code-debug.md)章节。
