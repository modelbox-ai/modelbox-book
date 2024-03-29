# 多设备开发

ModelBox支持应用在多设备上运行，其中包括Huawei Ascend、 Nvidia CUDA的支持。

## 功能单元与设备关系

应用由功能单元编排而成，因此应用的多设备运行，实际由功能单元在设备上的运行实现。在ModelBox中，定义每个功能单元需要声明其运行依赖的设备类型，且只能选择一种设备类型。例如框架中预置的resize功能单元，分别实现了依赖CPU、CUDA、Ascend的三个版本。这样每个功能单元就有了设备类型的属性。
在功能单元代码执行前，框架会自动设定当前线程的硬件上下文为指定设备的，如果需要额外获得本次执行指定的设备编号，可以通过成员变量获得Device ID，例如预置的torch推理功能单元中使用了Device ID指定了模型加载的设备。

## 功能单元设备类型的作用

设备类型的声明包含以下几个作用：

1. 功能单元的实现与设备相关，框架可以通过扫描当前运行环境中的硬件是否存在，决定功能单元的加载。
1. 功能单元声明与设备相关后，其输入默认会搬移到当前设备上，构建输出的内存空间时，分配的存储空间也在当前设备上。
1. 应用程序编排时，通过功能单元名和设备类型，即可选择指定的功能单元实现。

## 功能单元与硬件Stream接口

Nvidia GPU和Huawei Ascend硬件接口均提供了异步接口，在ModelBox中，对硬件上的内存管理均使用到了硬件Stream接口。在ModelBox中，发生数据从CPU拷贝到GPU或者Ascend的动作时，新的设备Buffer将会绑定一个Stream，此拷贝动作记录在Stream中，之后的功能单元进行处理时，也可以将异步动作施加到Stream上，而无需同步硬件的Stream。当数据要离开设备时，框架会在拷贝完毕后，自动进行必要的同步。
因此在编写GPU和Ascend功能单元时，需要注意，如果输入端口存在设备上的内存时，需要集成自设备功能单元接口，简化Stream的操作，如果输入端口均为CPU内存时，则需集成通用的功能单元接口。

具体设备上的开发如下：

| 设备   | 说明          | 链接                        |
| ------ | ------------- | --------------------------- |
| Ascend | Huawei Ascend | [链接](ascend.md) |
| CUDA   | Nvidia CUDA   | [链接](cuda.md)   |

## 多设备配置

多设备的配置是体现在图上的，在进行图编排时，应用需要对每个节点选择功能单元名，功能单元设备，以及设备的编号，这样就可以明确的指定该节点使用的功能单元实现及硬件情况。
除了选择特定设备外，ModelBox也支持了多设备自动选择的能力：

1. 指定功能单元、设备类型，不指定设备号，ModelBox会根据扫描到的指定设备类型的数量，自动使用这些设备上的功能单元处理数据。

2. 指定功能单元，不指定设备类型、设备号，ModelBox首先根据功能单元名称，查找所有同名的不同设备类型的实现，然后查看环境中的设备类型，确定可用的功能单元，再根据每个类型的设备数量，实例化对应数量的功能单元。最后自动使用这些设备上的功能单元进行数据处理。

配置样例:

1. 通过`deivce`和`deviceid`指定单个设备

    ``` graphviz
    resize[type=flowunit, flowunit=resize, device=cuda, deviceid=0, image_width=480, image_height=320]
    ```

1. 通过`device`指定单个设备

    ``` graphviz
    resize[type=flowunit, flowunit=resize, device="cuda:0", image_width=480, image_height=320]
    ```

1. 通过`device`指定同类型多个设备

    ``` graphviz
    resize[type=flowunit, flowunit=resize, device="cuda:0,1,3", image_width=480, image_height=320]
    ```

1. 通过`device`指定多个类型的多个设备

    ``` graphviz
    resize[type=flowunit, flowunit=resize, device="cuda:0,1,3;ascend:2,3,5", image_width=480, image_height=320]
    ```
