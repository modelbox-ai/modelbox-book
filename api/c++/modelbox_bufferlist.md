# modelbox::BufferList

|函数|作用|
|-|-|
|[构造方法](#构造方法)| bufferlist的构造方法|
|[Build](#build)|bufferlist对象申请指定长度大小的内存空间|
|[BuildFromHost](#buildfromhost)|bufferlist对象申请指定长度大小的内存空间|
|[Size](#size)|获取当前bufferlist的长度|
|[GetBytes](#GetBytes)|获取当前bufferlist的字节大小|
|[At](#At)|获取bufferlist当中特定位置的buffer|
|[遍历](#遍历)|遍历bufferlist|
|[EmplaceBack](#emplaceback)|把当前设备的数据塞入bufferlist当中|
|[EmplaceBackFromHost](#emplacebackfromhost)|把当前设备的数据塞入bufferlist当中|
|[ConstBufferData](#constbufferdata)|返回特定位置的buffer的数据常量指针|
|[MutableBufferData](#mutablebufferdata)|返回特定位置的buffer的数据指针|
|[CopyMeta](#copymeta)|把参数的bufferlist的meta信息，copy给当前bufferlist|
|[Set](#set)|设置当前bufferlist的某个meta值|
|[PushBack](#pushback)|将一个buffer插入到当前的bufferlist当中|

---

## 构造方法

BufferList申请内存空间

```c++
    BufferList();
    BufferList(const std::shared_ptr<Device>& device,
             uint32_t device_mem_flags = 0);
```

**args:**  

* **device** (modelbox::Device) —— 构建bufferlist的device对象
* **device_mem_flags** (uint32_t) —— device的内存的flag值，只有ascend才会使用，flag=1指的是dvpp的内存

```c++
    BufferList(const std::shared_ptr<Buffer>& buffer);
    BufferList(const std::vector<std::shared_ptr<Buffer>>& buffer_vector);
```

**args:**  

* **buffer** (modelbox::Buffer) —— 单buffer构造bufferList
* **buffer_vector** (vector) —— vector的buffer构建bufferlist

## Build

BufferList申请内存空间

```c++
    Status Build(const std::vector<size_t>& data_size_list,
                       bool contiguous = true)
```

**args:**  

* **data_size_list** (vector<size_t>) —— bufferlist当中每一个buffer的size大小
* **contiguous** (bool) —— bufferlist当中每个buffer的数据是否连续，默认连续

**return:**  

modelbox.Status 申请结果的状态

**example:**  

```c++
    #include <modelbox/buffer.h>

    Status Process(std::shared_ptr<DataContext> data_ctx) {
       auto output_bufs = data_ctx->Output("output");
       auto status = output_bufs->Build({1,1,1});
       MBLOG_INFO << output_bufs->Size();
       for (auto &buffer: output_bufs) {
           MBLOG_INFO << buffer->GetBytes();
       }
    }
        
```

**result:**

> 3
> 1  
> 1  
> 1

## BuildFromHost

BufferList从host侧申请内存空间

```c++
    Status BuildFromHost(const std::vector<size_t>& data_size_list,
                               void* data, size_t data_size,
                               DeleteFunction func = nullptr);
```

**args:**  

* **data_size_list** (vector<size_t>) —— bufferlist当中每一个buffer的size大小
* **data** (void*) —— 需要交给bufferlist的管理的host的数据指针
* **data_size** (size_t) —— 数据的大小
* **func** (std::function<void(void *)>) —— 析构的函数

**return:**  

modelbox.Status 申请结果的状态

**example:**  

```c++
    #include <modelbox/buffer.h>

    Status Process(std::shared_ptr<DataContext> data_ctx) {
       auto output_bufs = data_ctx->Output("output");
       vector<uint8_t> data{122,123,124}
       auto status = output_bufs->BuildFromHost({1,1,1}, data.data(), 3);
       MBLOG_INFO << output_bufs->Size();
       for (auto &buffer: output_bufs) {
           MBLOG_INFO << buffer->GetBytes() << ", " << *((uint8_t*)buffer->MutableData());
       }
    }
        
```

**result:**

> 3
> 1, 122
> 1, 123
> 1, 124

## Size

获取bufferlist的大小

**args:**  

无

**return:**  

size_t

## GetBytes

获取bufferlist 字节大小

**args:**  

无

**return:**  

size_t

## At

获取指定位置的buffer

**args:**  

* **pos** (size_t) 指定位置

**return:**

返回指定位置的shared_ptr<modelbox::Buffer>

## 遍历

遍历bufferlist

**example:**  

```c++
    #include <modelbox/buffer.h>

    Status Process(std::shared_ptr<DataContext> data_ctx) {
       auto output_bufs = data_ctx->Output("output");
       vector<uint8_t> data{122,123,124}
       auto status = output_bufs->BuildFromHost({1,1,1}, data.data(), 3);
       MBLOG_INFO << output_bufs->Size();
       for (auto &buffer: output_bufs) {
           MBLOG_INFO << buffer->GetBytes() << ", " << *((uint8_t*)buffer->MutableData());
       }

       auto buffer1 = output_bufs->At(1);
       MBLOG_INFO << *((uint8_t*)buffer->MutableData());
    }
        
```

**result:**

> 3
> 1, 122
> 1, 123
> 1, 124
> 123

## EmplaceBack

把当前设备的数据塞入bufferlist当中

```c++
    Status EmplaceBack(void* device_data, size_t data_size,
                     DeleteFunction func = nullptr);
    Status EmplaceBack(std::shared_ptr<void> device_data, size_t data_size);
```

**args:**  

* **device_data** (void*/std::shared_ptr<void>) —— 需要交给bufferlist的管理的device的数据指针
* **data_size** (size_t) —— 数据的大小
* **func** (std::function<void(void *)>) —— 析构的函数

**return:**  

modelbox.Status 插入到bufferlist的状态

## EmplaceBackFromHost

```c++
    Status EmplaceBackFromHost(void* host_data, size_t data_size);
```

**args:**  

* **host_data** (void*) —— 需要交给bufferlist的管理的host的数据指针
* **data_size** (size_t) —— 数据的大小

**return:**  

modelbox.Status 插入到bufferlist的状态

**example:**  

```c++
    #include <modelbox/buffer.h>

    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 该flowunit为1输入1输出，端口号名字分别为input, output
        ...
        auto device_ready_data1 = std::make_shared<uint8_t>(123);
        auto device_ready_data2 = std::make_shared<uint8_t>(124);
        auto host_ready_data1 = std::make_shared<uint8_t>(125);
        auto output_bufs =  data_ctx->Output("output");
        //析构时不做任何操作，释放的时间交给shared_ptr控制, 数据指针在device侧
        output_bufs->EmplaceBack(device_ready_data1.get(), 1, [](void*){})
        //智能指针交给buffer管理， 数据指针在device侧
        output_bufs->EmplaceBack(device_ready_data2, 1);
        //数据指针在host侧
        output_bufs->EmplaceBackFromHost(host_ready_data1.get(), 1);
        return STATUS_OK;
    }
        
```

**result:**

output_bufs插入了3个buffer

## ConstBufferData

```c++
    const void* ConstBufferData(size_t idx) const;
```

**args:**  

* **idx** (size_t*) —— 第idx数据

**return:**  

第idx buffer的数据常量指针

## MutableBufferData

```c++
    void* MutableBufferData(size_t idx);
```

**args:**  

* **idx** (size_t*) —— 第idx数据

**return:**  

第idx buffer的数据指针

**example:**  

```c++
    #include <modelbox/buffer.h>

    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto input_bufs = data->Input("input");
        for (auto i = 0; i < input_bufs->Size(); ++i) {
            // 通过buffer_list访问特定位置的数据指针，data1和data2是同一个指针
            void* data2 = input_bufs->ConstBufferData(i);
            ...
        }
    }
        
```

## CopyMeta

把参数的bufferlist的meta信息 copy给当前bufferlist

```c++
     Status CopyMeta(const std::shared_ptr<BufferList>& bufferlist,
                          bool is_override = false);
```

**args:**  

* **bufferlist** (modelbox::BufferList) —— meta来源的bufferlist
* **is_override** (bool) —— meta是否需要覆盖

**return:**  

modelbox::Status  返回CopyMeta接口Status

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
        output_bufs->Build({1});

        output_bufs->CopyMeta(input_bufs);
       
    }
        
```

**result:**

output_bufs具有和原始input_bufs相同的meta信息

## Set

给bufferlist当中每一个buffer都设置meta值

```c++
    template <typename T>
    void Set(const std::string& key, T&& value)
```

**args:**  

* **key** (str) —— meta的key值

* **value** (template) —— meta的value值

**return:**  

无

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
        output_bufs->Build({1});
        
        vector<int> shape{28,28};
        output_bufs->Set("shape", shape);
       
    }
        
```

**result:**

output_bufs当中的每一个buffer都一个meta值为shape

## PushBack

往bufferList当中push一个buffer

```c++
    void PushBack(const std::shared_ptr<Buffer>& buf)
```

**args:**  

* **buf** (modelbox::Buffer) —— 需要插入到bufferlist当中的buffer

**return:**  

无

**example:**  

```c++
   Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
        auto buffer = Buffer(GetBindDevice());
        
        output_bufs->PushBack(buffer);
       
    }
        
```

**result:**  

output_bufs当中push了一个buffer到数组内

# 更多的api可以参考容器当中拉起的api文档
