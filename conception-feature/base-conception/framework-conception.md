# 基本概念

ModelBox为更好的支撑应用流程，抽象了许多概念，理解这些概念对于应用问题的解决将会有很大帮助。

本章节主要从下图中的几个概念对ModelBox进行讲解，它们是ModelBox中十分重要的概念，开发者将时刻与它们打交道。

![flow-concept alt rect_w_1000](../assets/images/figure/framework-conception/flow-concept.png)

数据经由`INPUT Node`产生，按箭头指向，流向`Process Node`，`Process Node`处理数据后，在发送给`Sink Node`汇总处理结果，这是一个典型的数据处理过程，这个过程中，涉及到了图(Graph)、节点(Node)、端口(Port)、数据流(Stream)、数据缓存(Buffer)。

## Graph

图定义了ModelBox的执行过程，ModelBox根据图中指示的路径，调度Node的功能，处理[Buffer](#Buffer)数据。图的详细说明可阅读[图章节](graph.md)的内容。

## Flow

一个图构建完成后就是一个flow， 一个flow由多个node相连接构成。

## Node

图的基本组成，是功能单元在图中的实例化，和输入、输出Port一起组成了数据的处理实体。不同Node间由边(edge)连接，边是有向的。node也是数据流中的节点。node作为实际的数据处理单元，集成了flowunit、device管理、内存管理、端口管理等功能。 功能单元的详细说明可阅读[功能单元](flowunit.md)的内容。  

## Driver  

功能单元的实现单元。实现的具体的功能单元是作为driver加载在ModelBox中的。ModelBox服务在启动的时候，会加载指定目录下的所有的功能单元，作为driver库并管理。

## Port

节点上的数据连接点，可用于数据的输入或者输出，在图中两个Node之间的连接需要指定Port。

## Flowunit

driver是功能的抽象，那么flowunit就是功能的具体实现。当扫描完所有的driver之后，ModelBox会读取toml文件中的配置，通过flowunit_name以及配置创建driver抽象的实例，这个实例就称之为flowunit。根据不同的配置及配置参数，实现了不同的功能。当然除了创建实例的基本功能之外，还增加了一些例如内存管理、端口管理、设备管理等功能，详情请前往[flowunit](../flowunits/flowunits.md)和[device](../develop/device/device.md)的页面查看。

### Stream

一系列关联的顺序数据实体组成了数据流，在ModelBox中数据流是主要处理对象，比如视频流，音频数据流等。数据流的详细说明可阅读[Stream流](stream.md)的内容。  

### Buffer

流中包含多个数据实体，单个数据实体在ModelBox中由buffer承载。单个buffer包含了数据的元数据Meta部分和数据内容部分，它是数据在Node间的流动实体。Buffer的详细说明可阅读[Buffer](buffer.md)的内容。
