# 功能单元开发


在完成了流程图编排之后，还需通过功能单元(FlowUnit)来实现应用的实际功能。ModelBox加载功能单元后，根据图结构实例化为图中的各个节点。功能单元需提供特定的接口，根据接口协议在数据处理的各个阶段对接口进行调用。

有关功能单元的详细介绍，请先阅读[框架概念](../../framework-conception/framework-conception.md)章节，以及后续的[功能单元](../../framework-conception/flowunit.md)、[数据流](../../framework-conception/stream.md)章节内容。


本章节内容主要介绍功能单元的开发过程。

## 功能单元开发流程

![flowunit-develop](../../assets/images/figure/develop/flowunit/flowunit-develop.png)

1. 先从Example中复制样例代码。

1. 确定功能单元类型。
1. 修改Example代码的编译，TOML，源代码名称，和设置功能单元的输入，输出，参数，以及运行设备信息。
1. 根据需要实现FlowUnit的Open，DataPre，DataPost，Process，DataGroupPre，DataGroupPost，Close接口。
1. 编译连接外部组件，调用外部功能组件接口。
1. 编译安装包。
1. 流程图中配置使用功能单元。

## 功能单元类型


在开发功能单元时，应该先明确开发功能单元处理数据的类型，业务的场景。再根据上述信息选择合适的功能单元类型。
具体功能单元类型，请查看[功能单元](../../framework-conception/flowunit.md)中的`分类`。在确认功能单元类型后，需要对功能单元进行如下参数的配置。



功能单元参数说明：

|配置参数|是否必须设置|参数类型|功能描述|
|--|--|--|--|
|功能单元名称|是|String|功能单元名称|
|工作模式|是|FlowType|功能单元工作模式|
|添加功能单元输入|是|FlowUnitInput|设置输入端口和内存位置|
|添加功能单元输出|是|FlowUnitOutput|设置输出端口和内存位置|
|设置功能单元参数|是|FlowUnitOption|设置功能单元参数，包括参数名，类型，描述等信息|
|功能单元组类型|否|GroupType| |
|设置Driver描述|否|bool| |
|条件类型|否|ConditionType|是否为条件功能单元|
|输出类型|否|FlowOutputType|设置是否为扩张，或者合并功能单元|
|额外参数|否|String| |
|功能单元假名|否|String| |
|设置输入输出buffer数量是否相同|否|bool|仅流类型可设置，标识是否允许输入buffer和输出buffer数量不一致|
|设置输入是否连续|否|bool| |
|内存是否连续|否|bool|是否组装为连续内存|
|设置是否需要收齐buffer|否|bool|是否收集所有扩张的buffer。仅当收缩功能单元需设置，默认false|
|设置异常可见|否|bool| |
|设置虚拟类型|否|bool| | |

不同功能单元的配置如下：

|功能单元类型|配置参数|说明|
|--|--|--|

|通用功能单元| 工作模式设置为NORMAL | |
|条件功能单元| 工作模式设置为NORMAL，并且条件类型设置为IF_ELSE | |
|流数据功能单元| 工作模式设置为STEAM | |
|流数据拆分功能单元| 工作模式设置为STREAM，并且输出类型设置为扩张 | |
|流数据合并功能单元| 工作模式设置为STREAM，并且输出类型设置为合并 | |
|推理功能单元| 只需准备好模型和配置toml文件即可 | | |


## 功能单元接口说明

功能单元接口，包含功能单元`插件初始化接口`，`功能单元初始化接口`和`数据处理接口`。

### API接口类型实现对照关系

功能单元提供了FlowUnit::相关的接口，其接口按不同类型的功能单元而不同，开发者应根据FlowUnit处理数据的类型，选择实现相关的接口，对应的关系表如下：

|接口|接口类型|接口功能|调用实时机|是否必须|通用功能单元|条件功能单元|数据流功能单元|数据流拆分功能单元|数据流合并功能单元|
|--|--|--|--|--|--|--|--|--|--|
|DriverInit|插件初始化接口|模块初始化|插件加载时调用一次|否|✔️|✔️|✔️|✔️|✔️|
|DriverFini|插件初关闭接口|模块退出|插件结束时调用一次|否|✔️|✔️|✔️|✔️|✔️|
|FlowUnit::Open|功能单元初始化接口|功能单元初始化|图加载功能单元时调用|否|✔️|✔️|✔️|✔️|✔️|
|FlowUnit::Close|功能单元关闭接口|功能单元关闭|图结束时调用|否|✔️|✔️|✔️|✔️|✔️|
|FlowUnit::Process|数据处理接口|数据处理|有数据产生时调用|是|✔️|✔️|✔️|✔️|✔️|
|FlowUnit::DataGroupPre|数据处理接口|流数据合并开始|流数据合并时，流开始点触发|否|||||✔️|
|FlowUnit::DataGroupPost|数据处理接口|流数据合并结束|流数据合并时，流结束点触发|否|||||✔️|
|FlowUnit::DataPre|数据处理接口|流数据开始|流数据开始时触发|否||||✔️||
|FlowUnit::DataPost|数据处理接口|流数据结束|流数据结束时触发|否||||✔️|||

### 接口实现关系说明

1. 大部分情况下，业务都属于通用功能单元，仅需要处理单个数据，开发只需要实现FlowUnit::Process的功能即可。
1. 若功能单元需要处理流数据，或需要记录状态，对数据进行跟踪处理，则需要实现FlowUnit:DataPre, FlowUnit::Process, FlowUnit::DataPost接口的功能。
1. 若需要多数据合并，汇总结果，则需要实现FlowUnit::DataGroupPre, FlowUnit::DataPre, FlowUnit::Process, FlowUnit::DataPost, FlowUnit::DataGroupPost接口。
1. DriverInit, DriverFini, FlowUnit::Open, FlowUnit::Close在不同的时机触发，业务可根据需要实现相关的功能。比如初始化某些会话，句柄等资源。

#### 功能单元初始化、关闭

对应需实现的接口为`FlowUnit::Open`、`FlowUnit::Close`，此接口可按需求实现。例如，使用::Open接口获取用户在图中的配置参数，使用::Close接口释放功能单元的一些公共资源。

#### 数据处理

对应需实现的接口为`FlowUnit::Process`, Process为FlowUnit的核心函数。输入数据的处理、输出数据的构造都在此函数中实现。Process接口处理流程大致如下：

1. 从DataContext中获取Input输入BufferList，Output输出BufferList对象，参数为Port名称。

1. 使用Output->Build申请输出内存，内存和设备相关，设备在DriverDesc的时候设置。如是CPU则是CP内存，如是GPU则是GPU显存。
1. 循环处理每一个Input Buffer数据。
1. 对每一个Input Buffer数据可使用Get获取元数据信息。
1. 业务处理，根据需求对输入数据进行处理。
1. 构造output_buffer，并使用output_buffer->Build申请输出内存，内存和设备相关，设备DriverDesc的时候设置。如是CPU则是CPU内存，如是GPU则是GPU显存。
1. 对每一个Output Buffer数据可使用Set设置元数据信息。
1. 返回成功后，ModelBox框架将数据发送到后续的功能单元。

#### Stream流数据处理

对应需实现的接口为`FlowUnit::DataPre`、`FlowUnit::DataPost`，此接口Stream模式可按需实现。例如，处理一个视频流时，在视频流开始时会调用`DataPre`，视频流结束时会调用`DataPost`。FlowUnit可以在DataPre阶段初始化解码器，在DataPost阶段关闭解码器，解码器的相关句柄可以设置到DataContext上下文中。DataPre、DataPost接口处理流程大致如下：

1. Stream流数据开始时，在DataPre中获取数据流元数据信息，并初始化相关的上下文，存储DataContext->SetPrivate中。
1. 处理Stream流数据时，在Process中，使用DataContext->GetPrivate获取到上下文对象，并从Inpu中获取输入，处理后，输出到Output中。
1. Stream流数据结束时，在DataPost中释放相关的上下文信息。

#### 拆分合并处理

对应需实现的接口为`FlowUnit::DataGroupPre`、`FlowUnit::DataGroupPost`，当数据需要拆分合并时需要实现。
在业务处理过程中对数据进行拆分，然后在后续功能单元中处理，当数据处理完成后需要对数据进行合并得到最终结果。

对应的处理代码和DataPre，DataPost类似，如下图

![flowunit-collpase](../../assets/images/figure/develop/flowunit/flowunit-collpase.png)

如要将输入Stream1，Stream2，...合并为一个Stream。则接口调用过程为

1. DataGroupPre
1. DataPre, Stream1
1. DataPost, Stream1
1. DataPre, Stream2
1. DataPost, Stream2
1. ...
1. DataGroupPost

在编写代码时，其过程和DataPre类似，差别在于合并时对一组数据的归并动作：GroupPre中获取数据，并在Post中打开output的数据流上下文， 每个DataPre，DataPost中处理每个数据，最后在GroupPost中结束数据的合并。

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

## 多种语言开发功能单元

功能单元的开发可以使用多种语言，开发者可以使用合适的语言进行开发。

|方式|说明|适合类型|复杂度|连接|
|--|--|--|--|--|
|C++|C++ SDK形式|适合有高性能要求的功能开发，开发复杂度稍高。|⭐️⭐️⭐️|[指导](c++.md)|
|Python|Python SDK形式|适合对性能要求不高的功能开发，可快速上线运行。|⭐️⭐️|[指导](python.md)|
|模型|提供模型的形式|适合模型推理类功能的开发，直接提供模型即可运行，方便快捷。|⭐️|[指导](inference.md)|
