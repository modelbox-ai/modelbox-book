# 如何使用ModelBox

ModelBox的使用和其他服务类软件类似。流程上也是**安装运行环境**，**配置服务**，**开发业务**，**调试优化**，**部署运行**，**维护定位**。

ModelBox采用编排方式开发业务，这点和主流软件有一点不同。所以在开发前，需要对ModelBox的一些概念做了解。

## ModelBox必知概念

![modelbox-server alt rect_w_1280](../assets/images/figure/get-start/modelbox-server.png)

如图所示，开发者在使用ModelBox前，需要关注的基本核心概念包括：功能单元、流程图和接收数据处理请求的部分（REST API、Service）。

1. 流程图：  
ModelBox中用流程图(Graph)来表达应用逻辑。采用有向图的方式，将应用的执行逻辑表达为顶点和边，其中顶点表示了应用的某个数据处理逻辑单元，边则表示了逻辑单元之间的数据传递关系。在ModelBox中，针对流程图的开发，既可以使用文本方式直接编辑，也可以使用可视化的编辑器进行编辑。对于流程图的表述，ModelBox默认采用[Graphviz](https://www.graphviz.org/pdf/dotguide.pdf)进行解释，即图的表述需要满足Graphviz的语法要求。

1. 功能单元：  
ModelBox将流程图中的顶点称为功能单元(FlowUnit)。功能单元是应用的基本组成部分，也是ModelBox的执行单元。在ModelBox中，内置了大量的基础功能单元，开发者可以将这些功能单元直接集成到应用流程图中，这也是基于流程图开发的一大好处。除内置功能单元外，ModelBox支持功能单元的自定义开发，支持的功能单元形式多样，如C/C++动态库、Python脚本、模型+Toml配置文件等。

1. 接收数据处理请求：  
应用流程图构建完毕后，需要数据处理请求才能触发应用运行。ModelBox提供两种数据处理请求接收的方式：在flowunit中，通过在加载时调用API产生数据处理的请求，因为产生的请求是固定的，所以一般用于调试场景；标准使用方式是使用ModelBox提供的[服务插件](../develop/service-plugin/service-plugin.md)机制，在插件中接收外部请求，并调用任务相关的API来完成数据处理的请求。ModelBox提供了默认的服务插件可用于参考。数据处理请求的创建请详见[数据流](../framework-conception/stream.md)。

1. ModelBox：  
在应用构建完成后，结合ModelBox的框架才能形成完整可运行的应用。ModelBox作为应用入口，首先进行功能单元的扫描加载、应用流程图读取构建，然后接收数据处理请求，数据触发ModelBox中的执行引擎对功能单元进行调度，最终完成请求的数据处理任务。

1. 更多概念  
更详细的概念可以阅读[基本概念](../framework-conception/framework-conception.md)章节的内容。

## ModelBox使用流程（先介绍有哪几种使用方法：1、solution直接调用；2、sdk api集成；3、sevice模式。介绍这几种方式差异，开发模式）

ModelBox的开发使用流程指导，开发者可以在这里全局了解开发的过程。

推荐初次使用ModelBox的用户，先参照[第一个应用](../develop/first-app/first-app.md)的步骤操作，熟悉ModelBox的开发和使用过程。

**1. 环境准备：**

准备ModelBox运行或编译环境。下述两个步骤二选一即可，优先推荐使用已有镜像。

|步骤|说明|指导链接
|--|--|--|
|使用已经有镜像|ModelBox提供了多种推理Docker镜像，可以直接使用这些docker镜像来开发。|[链接](../faq/container-usage.md)
|源码构建ModelBox|在无可用镜像或参与ModelBox框架代码开发时，可以从源码构建ModelBox。|[链接](../compile/compile.md)

**2. 配置服务：**

ModelBox服务有两种工作模式，一种是生产使用的服务模式，一种是开发模式。

|步骤|说明|指导链接
|--|--|--|
|**服务模式**，运行ModelBox生产模式|用于生产环境运行AI流程图，ModelBox环境准备好后，默认情况下会启动ModelBox服务进程，生产环境中使用该模式。|[链接](../server/server.md)
|**开发者模式**，运行ModelBox开发模式|用于开发流程图时，可视化编排ModelBox流程图，提供了开发所需要的编排界面，开发环境下使用，同时也提供了体验内置推理方案的界面。|[链接](../server/editor.md)

**3. 推理业务开发：**

ModelBox的软件架构采用了分层，插件架构。开发者可以按照自己的诉求开发AI推理业务，或扩展ModelBox功能。开发上，可分为流程图开发，功能单元开发，服务插件开发和SDK集成ModelBox开发。

|开发内容|说明|指导链接
|--|--|--|
|解决方案体验|ModelBox内置了一些可用的解决方案和样例工程，开发者在开发业务之前，可以体验这些方案，以便更加了解ModelBox开发。此步骤非必须。|[链接](../develop/first-app/first-app.md)
|流程图开发|开发ModelBox运行的推理流程图，每个ModelBox推理业务都有一个流程图对应，所以需要先开发流程图。|[链接](../develop/flow/flow.md)
|功能单元开发|在完成了流程图编排之后，还需通过功能单元(FlowUnit)来实现应用的实际功能。|[链接](../develop/flowunit/flowunit.md)
|服务插件开发|此功能主要用于服务模式下，扩展ModelBox管理接口，比如需要扩展ModelBox任务管理，统计等你功能|[链接](../develop/service-plugin/service-plugin.md)
|SDK模式使用ModelBox|在已有进程中扩展推理业务，可以直接将上述步骤完成的AI推理功能，扩展到已有的进程中。提供了C++，Python接口，如果是新业务，推荐使用服务模式，避免从main函数开始。|[链接](../develop/sdk/sdk.md)|

**4. 调试优化：**

ModelBox的推理业务开发过程中，需要对开发的代码进行调试。ModelBox提供了相关的调试能力

|调试能力|说明|指导链接
|--|--|--|
|modelbox-tool|ModelBox运维调试工具，快速运行流程图，调整ModelBox服务日志，输出内存占用性能，模型加解密等功能|[链接](../develop/modelbox-tool/modelbox-tool.md)
|流程图性能调试|通过甘特图，输出流程图中每个节点的耗时时间，供优化功能单元，或队列，batchsize等使用。|[链接](../develop/debug/profiling.md)
|代码调试|功能单元有BUG的情况下，如何使用log，gdb，pdb，ide调试代码。|[链接](../develop/debug/debug.md)

**5. 服务运行：**

ModelBox开发完成后，需要部署到生产环境中运行，对应的需要对镜像，ModelBox软件，AI业务流程图进行配置。

|步骤|说明|指导链接
|--|--|--|
|运行已有的流程图|将开发完成后的流程图，部署到生产环境中运行。|[链接](../server/run-flow.md)
|发送REST-API请求|运行好流程图后，可以通过REST-API发送请求给ModelBox服务执行。|[链接](../api/rest.md)
