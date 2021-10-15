# 图

在Modelbox中由多个flowunit进行连接构成的实际业务的执行集合就是图。图是ModelBox的主要组件，ModelBox的数据处理过程，完全按照图中的拓扑关系进行。之前已经介绍过图的基本使用，本章主要介绍图的连接约束,图的加载方式，图的执行原理及优先级

## 图的连接约束

### 输入输出的约束

ModelBox中的图至少需要包含两种flowunit，source flowunit，sink flowunit。source flowunit只有输出无输入，如input，videoinput以及httpserver_sync_receive和httpserver_async_receive都属于这种功能单元。sink flowunit只有输入无输出，如output，httpserver_sync_reply和httpserver_async_reply，都属于这种功能单元。

ModelBox的图只能有一个source flowunit，这里主要是因为ModelBox中的运行的数据需要[匹配](../framework-conception/stream.md#为什么需要匹配)，如果数据源是不同的，则其中的数据不一定能匹配。比如写了两个httpserver_sync_receive的flowunit，则会启动两个http服务来接受不同的请求，但无法确定两边的请求数量是否完全一致，如数量不一致时会出现无法匹配的情况，导致图中的数据无法正常运行。这里存在一个例外，即一个图中input flowunit是可以有多个的，因为对其输入做了强制匹配的要求，即多个input输入的buffer的数量必须是一样多的。

ModelBox的图可以有多个sink flowunit，如可以使用多个output flowunit，默认情况下，多个output flowunit的输出是匹配的。如果输出的部分不匹配则需要在output的节点的配置上增加output_type=unmatch的配置

### 回路的约束

ModelBox的图不支持出现回路的情况，因为回路会导致数据会循环流动而无法消耗。

### 匹配的约束

ModelBox的图在拼接时会检查图中的节点的输入边的数据是否是[匹配](../framework-conception/stream.md#为什么需要匹配)的。如果出现某个节点输入的边互相不匹配则会报告图非法。详细的图匹配规则如下所示：

![match](../assets/images/figure/framework-conception/flowunit_match.png)

在上图中，第一个数据流在经过通用flowunit后，其产生的数据流与之前输入的数据流是可以匹配的，因此其输入输出数据流都是流a。第二个数据流在经过流flowunit后，其产生的数据流与之前输入的数据流是不可以匹配的，因此输入的数据流是流a，而输出的数据流是流b，流a与流b之间是无法匹配的。当功能单元的开发者确认流flowunit的输入输出数据是一样多的时候，可以在流flowunit中SetStreamSameCount(true)，增加了这个配置以后则输入和输出的数据都是流a，可以匹配。

![illegal_and_legal_graph_1](../assets/images/figure/framework-conception/illegal_and_legal_graph_1.png)

用户在开发时可以根据输入的流是否匹配来检查一下自己的图是否合法，在上图中左侧的图因为某一条边上加入了stream功能单元，产生了流b，流b与流a无法匹配，因此左图是一个非法图。将该stream功能单元SetStreamSameCount(true)后其输出的流恢复为流a,可以匹配。因此右图可以正常运行。

### 条件分支的约束

在图中有条件功能单元的情况下，主流不能与子流做匹配，只有等全部的子流聚合恢复为主流后才可以与主流进行匹配。子流和主流的关系在[条件功能单元数据处理](../framework-conception/stream.md#条件功能单元数据处理)有更详细的介绍

![illegal_and_legal_graph_2](../assets/images/figure/framework-conception/illegal_and_legal_graph_2.png)

如上图所示，在左图中经过条件功能单元后，主流a会产生分流a1和分流a2，分流a1和分流a2都只有主流a的部分数据，因此不可以与主流a直接进行匹配，因此左图是非法的。在右图中，分流a1和分流a2在最后的通用功能单元聚合后恢复成主流a，可以与主流a进行匹配，因此该图是合法的

同时条件功能单元不允许在子流上添加流Flowunit，因为流Flowunit会按照主流中的序号顺序运行，而在子流中会出现缺失序号顺序的情况。如下图所示：

![illegal_and_legal_graph_3](../assets/images/figure/framework-conception/illegal_and_legal_graph_3.png)

左图是一个非法的图，因为其在condition算子后的一个分路上加入了一个流Flowunit。右图将其流Flowunit设置为通用的Flowunit后，图恢复为合法图

### 层级的约束

在图有层级的情况下，子层与父层之间不能直接进行匹配。需要先将子层归拢为父层之后才能进行匹配。关于子层与父层之间的关系在[数据流层级](../framework-conception/stream.md#数据流层级)有更详细的介绍

![illegal_and_legal_graph_4](../assets/images/figure/framework-conception/illegal_and_legal_graph_4.png)

左图中父流a在通用Flowunit 2上与子流a1和子流a2是无法匹配的才，因此左图是非法的。在右图中，将子流a1和子流a2收拢成为父流a后即可以与通用功能单元的另一路父流a进行匹配，因此右图是合法的

## 图的加载过程

图的加载过程如下所示：

![graph-process](../assets/images/figure/framework-conception/graph-process.png)

## 图的执行及优先级

在图被放入调度器后，调度器会按照拓扑结构对图进行优先级排序，即越靠近出口的节点的优先级越高，这样做的目的是为了保证现有的请求可以尽快的完成，而不至于在入口处累计过多的buffer造成内存或显存的浪费。节点的优先级如下图所示：

![graph-priority](../assets/images/figure/framework-conception/graph-priority.png)

当图中的某个节点收到数据时，会触发调度器去使用一个线程去执行该节点的run函数，并处于running状态直到run函数执行完毕。当该节点处在running状态的时候，后续的收到的数据会填入该节点的接收队列，但并不会触发run函数，直到该节点执行完run函数。在run的过程中，数据会按照流或者batch切分成多份，放入不同的线程去执行。当线程数量不够时，高优先级的节点会优先放入待执行的队列中，已保证高优先节点可以更快的完成。
