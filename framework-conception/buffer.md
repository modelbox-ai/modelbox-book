# Buffer

Buffer是ModelBox中功能单元之前传递数据的唯一载体。采用Buffer进行传递的主要原因是功能单元会运行在多种设备上，因此当前功能单元实现时，不应假设其之前或者之后的功能单元所使用的内存属于哪一个设备，当前功能单元只需要指明其输入所期望的设备是什么，由框架完成数据的搬移工作，以降低功能单元的连接限制。

## Buffer与数据的传递

在ModelBox的功能单元开发中，Buffer作为功能单元的输入或者输出数据的载体出现，对其使用的了解是基于ModelBox开发的基本要求，同时了解其如何承载数据、数据的存储规范对于更好的开发功能单元将会有很大帮助。

功能单元进行数据处理时，其process将要对输入数据完成操作，并产生输出，这个过程中，用户将从DataContext中获取到本次需要处理的数据。ModelBox根据如下因素的影响来决定本次需要处理的数据：

1. 当前节点存在一个输入队列，用来存放最近未处理的数据，其长度可以通过配置进行设定。
1. 当节点触发调用运行时，会将队列中的数据全部取出，准备进行处理。
1. 数据取出后，调用process处理时，存在batch_size的选项，即每次process最多可以处理的数据量。框架根据batch_size和功能单元的类型对数据进行划分，同时将数据搬移到功能单元指定的输入设备上，最终决定了process调用的次数，以及每次process调用时的数据数量。

在功能单元开发者的process函数看到的输入BufferList便是在框架中完成了拆分后本次process需要处理的数据列表，列表满足的约束请参考[流算子](./flowunit.md)章节。

输出数据时，首先要从DataContext中取出的输出BufferList，然后进行BufferList的Build，或者在创建Buffer时使用GetBindDevice，这两个操作都会为输出的内存指定设备，保证输出的数据分配在指定的设备上。

## Buffer的约束

* 作为输入数据时，不应当对当前内存进行修改，因此对象内存已被标记未数据不可修改的状态，此时读取数据需要使用ConstData来获得数据指针。

* 作为输出数据时，buffer的持有者唯一，它是可以写入的，需要调用MutableData返回数据指针，并对其进行写入。

* 数据主体应当存放于Buffer里获取的数据指针所指向的存储空间，对于当前数据的描述信息即元数据则需要存放在Buffer->Set中，因为这类元信息是与设备无关的，只需要一直保存在主机内存里即可。

## Buffer常用接口介绍

以下列表展现了较为常用的Buffer的成员函数。

|                             函数名称                                  |           返回值类型     | 函数功能 |
| -------------------------------------------------------------------- | ----------------------- | ---------- |
| MutableData()                                                        | void*                   | 获取buffer可变数据的指针 |
| ConstData() const                                                    | const void*             | 获取buffer常量数据的指针 |
| GetBytes() const                                                     | size_t                  | 获取buffer的字节大小 |
| Get(const std::string& key)                                          | std::tuple<Any*, bool>  | 根据meta的键获取相对应的值|
| GetDevice()                                                          | std::shared_ptr<Device> | 返回buffer所对应的设备|
| Get(const std::string& key, T&& value)                               | bool                    | 在buffer中是否存在meta的key值|
| Set(const std::string& key, T&& value)                               | void                    | 给buffer设置meta的键值对|
| CopyMeta(const std::shared_ptr<Buffer> buf, bool is_override = false)| Status                  | 复制buf的meta值|
| Copy()                                                               | std::shared_ptr<Buffer> | buffer的浅拷贝|
| DeepCopy()                                                           | std::shared_ptr<Buffer> | buffer的深拷贝|

## BufferList

BufferList是Buffer的vector集合。ModelBox提供了完备的api，可以简单地批量修改Buffer。
其中，`BufferList->At(idx)`可直接用`BufferList[idx]`代替。

|                                    函数名称                                  |           返回值类型     | 函数功能 |
| --------------------------------------------------------------------------- | ----------------------- | ---------- |
| MutableData()                                                               | void*                   | 获取bufferList首个buffer的可变数据的指针 |
| ConstData()                                                                 | const void*             | 获取bufferList首个buffer的常量数据的指针 |
| MutableBufferData(size_t idx)                                               | void*                   | 获取bufferList首个buffer的可变数据的指针 |
| ConstBufferData(size_t idx) const                                           | const void*             | 获取bufferList首个buffer的常量数据的指针 |
| GetBytes()                                                                  | size_t                  | 获取bufferList的字节大小 |
| Size()                                                                      | size_t                  | 获取bufferList的长度 |
| GetDevice()                                                                 | std::shared_ptr<Device> | 返回bufferList的首个buffer所对应的设备|
| At(size_t idx)                                                              | std::shared_ptr<Buffer> | 根据索引值 返回此处的buffer |
| PushBack(const std::shared_ptr<Buffer>& buf)                                | void                    | 将新的buffer加入到bufferList末尾 |
| Set(const std::string& key, T&& value)                                      | void                    | 给bufferList中所有buffer设置相同的meta键值对|
| CopyMeta(const std::shared_ptr<Buffer> bufferList, bool is_override = false)| Status                  | 复制传入函数中的另一个bufferList的meta值|
| MakeContiguous()                                                            | Status                  | 使bufferList在显存或者内存中连续|
| Reset()                                                                     | Status                  | 清空bufferList |
