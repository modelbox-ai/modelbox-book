# modelbox::Buffer

|函数|作用|
|-|-|
|[构造方法](#构造方法)| buffer的构造方法|
|[Build](#build)|buffer申请特定大小的内存，内存来源于device侧|
|[BuildFromHost](#buildfromhost)|buffer申请特定大小的内存，内存来源于host侧|
|[ConstData](#constdata)|获取当前buffer的数据的常量指针|
|[MutableData](#mutabledata)|获取当前buffer的数据的指针|
|[HasError](#haserror)|判断buffer是否存在error|
|[SetError](#seterror)|给buffer设置error|
|[GetErrorCode](#geterrorcode)|获取error_code|
|[GetErrorMsg](#geterrormsg)|获取error_msg|
|[GetBytes](#getbytes)|获取当前buffer的字节数|
|[Get](#get)|获取指定key的meta值|
|[Set](#set)|设置指定key的meta值|
|[CopyMeta](#copymeta)|拷贝指定buffer的所有meta值给新buffer|
---

## 构造方法

构造新的buffer

```c++
    Buffer();
    Buffer(const std::shared_ptr<Device>& device, uint32_t dev_mem_flags = 0);
```

**args:**

* **device** (modelbox::Device) —— 构造当前buffer所在的modelbox::Device对象
* **dev_mem_flags**  (uint32_t) —— ascend memory的类型，默认为Normal型

**return:**  

构造出来的新的buffer

**note:**

1. dev_mem_flags改参数只在ascend的内存上面有区分，0为普通内存类型，1位dvpp内存，其他设备不需要区分

**example:**

```c++
   #include <modelbox/buffer.h>

   Status Process(std::shared_ptr<DataContext> data_ctx) {
       auto buffer = std::make_shared<Buffer>(GetBindDevice());
   }
        
```

**result:**

构建出了和当前流单元在同一个设备上面的buffer对象

## Build

通过buffer对象构建特定大小的内存

```c++
    Status Build(size_t size);
    //data在device侧
    Status Build(void* data, size_t data_size,
                       DeleteFunction func = nullptr);
```

**args:**  

* **size** (size_t) —— buffer申请的内存字节大小
* **data** (void*) 构建给buffer管理的数据指针
* **data_size** (size_t) —— buffer申请的内存字节大小
* **func** (DeleteFunction ) —— 释放buffer指针的函数

## BuildFromHost

```c++
    // data在host侧
    Status BuildFromHost(void* data, size_t data_size,
                               DeleteFunction func = nullptr);
```

**args:**  

* **data** (void*) 构建给buffer管理的数据指针
* **data_size** (size_t) —— buffer申请的内存字节大小
* **func** (DeleteFunction ) —— 释放buffer指针的函数

**return:**  

modelbox::Status, 构建buffer的返回的status状态

**example:**  

```c++
    #include <modelbox/buffer.h>

    Status Process(std::shared_ptr<DataContext> data_ctx) {
       auto buffer1 = std::make_shared<Buffer>(GetBindDevice());
       auto buffer2 = std::make_shared<Buffer>(GetBindDevice());
       auto buffer3 = std::make_shared<Buffer>(GetBindDevice());
       Status status{STATUS_OK};
       status = buffer1->Build(1);
       auto *data = buffer1->MutableData();
       data[0] = 122;

       auto device_data = std::make_shared<uint8_t>(123);
       status = buffer2->Build(device_data.get(), 1);

       auto host_data = std::make_shared<uint8_t>(124);
       status = buffer3->Build(host_data.get(), 1, [](void *){});
    }
        
```

**result:**  

构建成功了3个buffer，通过不同的方式申请内存赋值

## ConstData

获取buffer的原始数据的常量指针

**args:**  

无

**return:**  

const void*, 原始数据的常量指针

## MutableData

获取buffer的原始数据的指针

**args:**  

无

**return:**  

void*, 原始数据的指针

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该流单元为1输入1输出，输入端口名为input，输出端口名为output
        auto input_bufs = data->Input("input");
        auto output_bufs = data->Output("output");
        for (auto i = 0; i < input_bufs->Size(); ++i) {
            // 指定位置的buffer
            auto buffer = input_bufs->At(i);
            // 数据原始指针
            const void* data1 = buffer->ConstData();
        }

        ...
        // output_bufs已经构建好了内存以及数据
        for (auto i = 0; i < output_bufs->Size(); ++i) {
            // 指定位置的buffer
            auto buffer = output_bufs->At(i);
            void* data2 = buffer->MutableData();
        }
    }
        
```

**result:**

data1和data2为获取buffer的数据指针

**note:**

1. input的bufferList当中获取数据用ConstData()接口，output的bufferList当中获取数据使用MutableData()接口

1. 流单元当中的输入数据是为不可变，输出数据需要构造赋值，为可变。  

## HasError

```c++
    bool HasError() const;
```

**args:**  

无

**return:**  

bool, 当前buffer是否存在error

## SetError

```c++
    void SetError(const std::string& error_code,
                           const std::string& error_msg);
```

**args:**  

* **error_code** (string) —— error的错误码

* **error_msg** (string) —— error的错误信息

**return:**  

无

## GetErrorCode

```c++
    std::string GetErrorCode() const;
```

**args:**  

无

**return:**  

string, 当前buffer的错误码

## GetErrorMsg

```c++
    std::string GetErrorMsg() const;
```

**args:**  

无

**return:**  

string, 当前buffer的错误信息

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该流单元为1输入1输出，输入端口名为input，输出端口名为output
        ...
        auto output_bufs = data->Output("output");
        output_bufs->Build({1,1,1});
        for (auto i = 0; i < output_bufs->Size(); ++i) {
            auto buffer = output_bufs->At(i);
            bool error = true;
            if (error) {
                buffer->SetError("Sample.FAILED_001", "test error");
            }
        }
    }

    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该流单元为1输入1输出，输入端口名为input，输出端口名为output
        auto input_bufs = data->Input("input");
        auto output_bufs = data->Output("output");
        for (auto i = 0; i < input_bufs->Size(); ++i) {
            auto buffer = input_bufs->At(i);
            if (buffer->HasError()) {
                auto error_code = buffer->GetErrorCode();
                auto error_msg = buffer->GetErrorMsg();
            }
        }
    }

```

**result:**

可以在报错时给buffe设置error，然后在其他流单元里面补充获取存在buffer的error_code和error_msg

## GetBytes

获取当前buffer的字节数

```c++
    size_t GetBytes() const;
```

**args:**  

无

**return:**  

int64, buffer的bytes

**example:**  

```c++
    
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该流单元为1输入1输出，输入端口名为input，输出端口名为output
        ...
        auto output_bufs = data->Output("output");
        output_bufs->Build({1,1,1});
        for (auto i = 0; i < output_bufs->Size(); ++i) {
            auto buffer = output_bufs->At(i);
            auto bytes = buffer->GetBytes();
        }
    }
        
```

**result:**

获取该buffer的bytes

## Set

设置当前buffer的某个meta值

```c++
    template <typename T>
    void Set(const std::string& key, T&& value)
```

**args:**  

* **key** (str) —— meta的key值

* **value** (template) —— meta的value值

**return:**  

无

## Get

获取当前buffer的某个meta值

```c++
    template <typename T>
    bool Get(const std::string& key, T&& value)
```

**args:**  

* **key** (str) —— meta的key值
* **value** (template) —— 接收meta的value值

**return:**  

bool, 是否获取meta值成功

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto buffer = input_bufs->At(0);
        // 获取buffer meta当中的shape信息，res为get的结果
        std::vector<int> shape;
        auto res = buffer->Get("shape", shape);
        if (!res) {
            return STATUS_FAULT;
        }
        
        // 更新shape值后重新，设置到out_buffer的meta当中
        auto output_bufs = data_ctx->Output("output");
        shape.push_back(1);
        auto out_buffer = output_bufs->At(0);
        out_buffer->Set("shape", shape);
    }
```

## CopyMeta

把参数的buffer的meta信息 copy给当前buffer

```c++
    Status CopyMeta(const std::shared_ptr<Buffer> buf,
                          bool is_override = false)
```

**args:**  

* **buf** (modelbox::Buffer) —— meta来源的buffer
* **is_override** (bool) —— meta是否需要覆盖

**return:**  

modelbox::Status  返回CopyMeta接口Status

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
        auto buffer = input_bufs->At(0);
        output_bufs->Build({1});

        auto new_buffer = output_bufs->At(0);
        new_buffer->CopyMeta(buffer);
       
    }
        
```

**result:**

new_buffer具有和原始buf相同的meta信息
