# 基础概念

ModelBox为更好的支撑应用流程，抽象了许多概念，理解这些概念对于应用问题的解决将会有很大帮助。

本章节主要从下图中的几个概念对ModelBox进行讲解，它们是ModelBox中十分重要的概念，开发者将时刻与它们打交道。

通过ModelBox开发应用时，开发者需要将应用程序的逻辑表达为流程图，应用功能被拆分为多个功能单元。采用这种方式的目的是：对数据流(如视频)处理可以利用多段流水线并行提供吞吐量；通用的功能单元可以复用；通用的流程图可以复用。  

![flow-concept alt rect_w_1000](../../assets/images/figure/framework-conception/flow-concept.png)

数据经由`INPUT Node`产生，按箭头指向，流向`Process Node`，`Process Node`处理数据后，在发送给`Sink Node`汇总处理结果，这是一个典型的数据处理过程，这个过程中，涉及到了图(Graph)、节点(Node)、端口(Port)、数据流(Stream)、数据块(Buffer)。

## [图](graph.md)

图章节将从构成、连接、执行等方面进行介绍，包含了图、节点、端口、边的概念。

## [功能单元](flowunit.md)

功能单元是重要的用户接口，应用的功能需通过多个单元才能实现。本章介绍将较为系统的介绍功能单元相关的信息。

## [数据流](stream.md)

一系列关联的顺序数据实体组成了数据流，在ModelBox中数据流是主要处理对象，比如视频流，音频数据流等。

## [Buffer](buffer.md)

流中包含多个数据实体，单个数据实体在ModelBox中由buffer承载。单个buffer包含了数据的元数据Meta部分和数据内容部分，它是数据在Node间的流动实体。
