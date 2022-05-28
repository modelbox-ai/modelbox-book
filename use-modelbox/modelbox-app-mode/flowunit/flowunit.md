# 功能单元开发（本章节主要讲如何具体使用，只讲常见的使用方式，细节，全量的参数概念拆分在概念，api文档中）

在完成了流程图编排之后，还需通过功能单元(FlowUnit)来实现应用的实际功能。ModelBox加载功能单元后，根据图的结构，将实例化为图中的各个节点。功能单元需提供特定的接口，根据接口协议，在数据处理的各个阶段对接口进行调用。

有关功能单元的详细介绍，请先阅读[基本概念](../../../basic-conception/basic-conception.md)章节，以及后续的[功能单元](../../../basic-conception/flowunit.md)、[数据流](../../../basic-conception/stream.md)章节内容。

本章节内容主要介绍功能单元的开发过程。

## 功能单元开发流程

1. 通过modelbox-tool 创建项目模板

```shell
    modelbox-tool template -project -name="project"
```

项目工程创建默认路径为当前用户的modelbox-project下面

1. 可以通过 modelbox-tool 创建功能单元模板工程

```shell
    modelbox-tool template -flowunit -lang c++ -name [name] -input name=in1,device=cuda -output -
```

有关modelbox-tool template的功能参见modelbox-tool那一章节

1. 根据具体情况可以修改Example代码的编译，TOML，源代码名称，和设置功能单元的输入，输出，参数，以及运行设备信息。
1. 根据需要实现FlowUnit的Open，DataPre，DataPost，Process，Close接口。
1. 编译生成动态库以及安装包，安装到系统当中去。
1. 流程图中配置使用功能单元。

## 功能单元类型

在开发功能单元时，应该先明确开发功能单元处理数据的类型，业务的场景。再根据上述信息选择合适的功能单元类型。
具体功能单元类型，请查看[功能单元类型](../../../basic-conception/flowunit.md##功能单元类型)。在确认功能单元类型后，需要对功能单元进行如下参数的配置。

功能单元参数说明：

| 配置项                     | 属性名          | 必填 | c++参数类型    | 功能描述                                                                 |
| -------------------------- | -------------------- | ---- | -------------- | ------------------------------------------------------------------------ |
| 功能单元名称               | flowunit_name      |  是   | String         | 功能单元名称                                                             |
| 功能单元描述               | flowunit_description       |  否   | String         | 功能单元描述                                                             |
| 功能单元组类型             | group_type |  否   | GroupType      | 功能单元分类                                                             |
| 功能单元数据处理类型           | flow_type          |  是   | FlowType       | 功能单元数据处理类型 ，分为NORMAL 和 STREAM                                    |
| 功能单元输入端口           | flowunit_input_list     |  是   | FlowUnitInput  | 设置输入端口和数据存放设备                                               |
| 功能单元输出端口           | flowunit_output_list |  是   | FlowUnitOutput | 设置输出端口和数据存放设备                                               |
| 功能单元配置参数           | flowunit_option_list    |  是   | FlowUnitOption | 设置功能单元配置参数，包括参数名，类型，描述等信息                       |
| 条件类型                   | condition_type     |  否   | ConditionType  | 是否为条件功能单元                                                       |
| 输出类型                   | output_type        |  否   | FlowOutputType | 设置是否为扩张或者合并功能单元                                           |
| 输入内存是否连续           | is_input_contiguous   |  否   | bool           | 是否要求输入内存是否是分配的连续空间                                     |
| 异常是否可见               | is_exception_visible  |  否   | bool           | 本功能单元是否处理前面功能单元的异常消息                                 |
| Driver名称                 | driver_name              |  是   | String         | driver描述                                                               |
| Driver功能类型             | driver_class             |  是   | String         | driver功能类型，功能单元类型为DRIVER-FLOWUNIT                            |
| Driver设备类型             | driver_type              |  是   | String         | driver描述，cuda/cpu/ascend类型                                          |
| Driver版本号               | driver_version          |  是   | String         | driver版本号                                                             |
| Driver描述                 | driver_description       |  是   | String         | driver功能描述                                                           |

Driver和功能单元的关系：Driver是ModelBox中各类插件的集合，功能单元属于Driver中的一种类型。在C++语言中，一个Driver对应一个so，一个Driver可以支持多个功能单元，即将多个功能单元编译进一个so文件。而再python中，Driver和功能单元一一对应。

根据业务类型，常用功能单元的可以分为以下几类:

| 功能单元类型       | 配置参数                                        | 适用场景                                                           |
| ----------------- | ----------------------------------------------- | ------------------------------------------------------------------ |
| 通用功能单元       | 类型设置为NORMAL                            | 图像操作，如resize                                                 |
| 流数据功能单元     | 类型设置为STREAM                            | 视频流的处理，可以感知任务的开始结束                               |
| 条件功能单元       | 类型设置为NORMAL，并且条件类型设置为IF_ELSE | 业务逻辑的分支判断                                                 |
| 流数据展开功能单元  | 类型设置为NORMAL，并且输出类型设置为展开    | 一张图片推理出多辆车，多每辆车做车牌检测，再讲整张图的所有车牌汇总 |
| 流数据合并功能单元  | 类型设置为NORMAL，并且输出类型设置为合并    | 一张图片推理出多辆车，多每辆车做车牌检测，再讲整张图的所有车牌汇总 |                                                                   |

## 功能单元开发说明

功能单元开发分为三步，包含`插件信息定义`，`功能单元信息定义`和`功能单元数据处理`。

### 插件信息定义

这里的插件定义即为driver对象的信息定义以及初始化，c++和python的定义各不相同。

可以分别参照[c++流单元开发](c++.md#driver接口说明)和[python流单元开发](python.md#toml配置)

详细插件属性接口可以参考[driver_desc接口](../../api/c++/modelbox_driverdesc.md)

### 功能单元信息定义

同样的分为[c++功能流单元](c++.md#flowunit属性设置)以及通过配置文件配置的[python流单元](python.md#toml配置)以及[推理流单元](inference.md#推理功能流单元配置toml格式)

详细流单元属性接口定义可以参考[flowunit_desc接口](../../api/c++/modelbox_flowunitdesc.md)

### 接口实现关系说明

1. 大部分情况下，业务都属于通用功能单元，仅需要处理单个数据，开发只需要实现FlowUnit::Process的功能即可。
1. 若功能单元需要处理流数据，或需要记录状态，对数据进行跟踪处理，则需要实现FlowUnit:DataPre, FlowUnit::Process, FlowUnit::DataPost接口的功能。
1. DriverInit, DriverFini, FlowUnit::Open, FlowUnit::Close在不同的时机触发，业务可根据需要实现相关的功能。比如初始化某些会话，句柄等资源。

#### 功能单元初始化、关闭

对应需实现的接口为`FlowUnit::Open`、`FlowUnit::Close`，此接口可按需求实现。例如，使用::Open接口获取用户在图中的配置参数，使用::Close接口释放功能单元的一些公共资源。

### 数据处理

对应需实现的接口为`FlowUnit::Process`, Process为FlowUnit的核心函数。输入数据的处理、输出数据的构造都在此函数中实现。Process接口处理流程大致如下：

1. 从DataContext中获取Input输入BufferList，Output输出BufferList对象，参数为Port名称。
1. 循环处理每一个Input Buffer数据。
1. 对每一个Input Buffer数据可使用Get获取元数据信息。
1. 业务处理，根据需求对输入数据进行处理。
1. 构造output_buffer
1. 对每一个Output Buffer数据可使用Set设置元数据信息。
1. 返回成功后，ModelBox框架将数据发送到后续的功能单元。

具体样例可以参考[数据处理](buffer.md)

#### Stream流数据处理

对应需实现的接口为`FlowUnit::DataPre`、`FlowUnit::DataPost`，此接口Stream模式可按需实现。例如，处理一个视频流时，在视频流开始时会调用`DataPre`，视频流结束时会调用`DataPost`。FlowUnit可以在DataPre阶段初始化解码器，在DataPost阶段关闭解码器，解码器的相关句柄可以设置到DataContext上下文中。DataPre、DataPost接口处理流程大致如下：

1. Stream流数据开始时，在DataPre中获取数据流元数据信息，并初始化相关的上下文，存储DataContext->SetPrivate中。
1. 处理Stream流数据时，在Process中，使用DataContext->GetPrivate获取到上下文对象，并从Input中获取输入，处理后，输出到Output中。
1. Stream流数据结束时，在DataPost中释放相关的上下文信息。

具体样例可以参考上下文样例的使用[context使用](context.md)

## 上下文

功能单元上下文包含，`会话上下文|SessionContext`和`数据上下文|DataContext`

### SessionContext 会话上下文

SessionContext主要供调用图的业务使用，业务处理数据时，设置状态对象。

* 生命周期

绑定ExternalData，从数据进入Flow，贯穿整个图，一直到数据处理完成结束。

* 使用场景

例如http服务同步响应场景，首先接收到http请求后转化成buffer数据，然后通过ExternalData->GetSessionContext接口获取到SessionContext，接着调用SessionContext->SetPrivate设置响应的回调函数，之后通过ExternalData->Send接口把buffer数据发送到flow中；经过中间的业务处理功能单元；最后http响应功能单元中在业务数据处理完成后，再调用SessionContext->GetPrivate获取响应回调函数，发送http响应。至此SessionContext也结束。

### DataContext 数据上下文

DataContext是提供给当前功能单元处理数据时的临时获取BufferList
功能单元处理一次Stream流数据，或一组数据的上下文，当数据生命周期不再属于当前功能单元时，DataContext生命周期也随之结束。

* 生命周期

绑定BufferList，从数据进入FlowUnit到处理完成。

* 使用场景

通过DataContext->Input接口获取输入端口BufferList，通过DataContext->Output接口获取输出端口BufferList对象,通过DataContext->SetPrivate接口设置临时对象，DataContext->GetPrivate接口获取临时对象。

## 功能单元处理异常

开发者在运行流程图和开发流程图的过程当中，需要针对功能单元的情况返回异常，并且能够可以在其他业务功能单元中捕获当前异常进行自定义处理，modelbox即可提供该场景下异常捕获处理的能力。

具体可以参考[指导](../../../other-features/exception.md)。

## 多种语言开发功能单元

功能单元的开发可以使用多种语言，开发者可以选择使用合适的语言进行开发，也可以多种方式混合。

| 方式     | 适合类型                                                   | 复杂度 | 连接                 |
| -------- | ---------------------------------------------------------- | ------ | -------------------- |
| C++      | 适合有高性能要求的功能开发，需要编译成so，开发复杂度稍高。 | ⭐️⭐️⭐️    | [指导](c++.md)       |
| Python   | 适合对性能要求不高的功能开发，可快速上线运行。             | ⭐️⭐️     | [指导](python.md)    |
| 配置文件 | 适合模型推理类功能的开发，直接提供模型即可运行，方便快捷。 | ⭐️      | [指导](inference.md) |
