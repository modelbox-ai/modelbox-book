# C++ API(对接口做分类)

在ModelBox服务启动，并开启Editor编辑器后，可直接使用`http://[host]:1104/api/`访问。

# **分类列表可参考：**

## (flowunit)

flowunit 

datacontext

sessioncontext

configuration

flowunitevent

flowuniterror

datameta

## (graph)

flow

## （buffer)

buffer

bufferlist

device

## (server-plugin)

...

|组件名|功能|
|-|-|
|[Buffer](c++/modelbox_buffer.md)| modelbox存储基本数据的数据结构|
|[BufferList](c++/modelbox_bufferlist.md)| modelbox存储基本数据的数据结构|
|[FlowUnit](c++/modelbox_flowunit.md)| modelbox最基本的编排单元|
|[DataContext](c++/modelbox_datacontext.md)| modelbox流单元当中储存数据的数据结构|
|[Configuration](c++/modelbox_configuration.md)| modelbox存放配置项的数据结构|
|[DataMeta](c++/modelbox_datameta.md)| modelbox挂在端口上面存放数据元信息的数据结构|
|[FlowUnitEvent](c++/modelbox_flowunitevent.md)| modelbox中描述event的数据结构|
|[SessionContext](c++/modelbox_sessioncontext.md)| modelbox描述会话上下文的数据结构|
