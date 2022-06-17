# modelbox::Buffer

|函数|作用|
|-|-|
|[构造方法](#构造方法)| Buffer的构造方法|
|[Build](#build)|Buffer申请特定大小的内存，内存来源于device侧|
|[BuildFromHost](#buildfromhost)|Buffer申请特定大小的内存，内存来源于host侧|
|[ConstData](#constdata)|获取当前Buffer的数据的常量指针|
|[MutableData](#mutabledata)|获取当前Buffer的数据的指针|
|[HasError](#haserror)|判断Buffer是否存在error|
|[SetError](#seterror)|给Buffer设置error|
|[GetErrorCode](#geterrorcode)|获取error_code|
|[GetErrorMsg](#geterrormsg)|获取error_msg|
|[GetBytes](#getbytes)|获取当前Bufferr的字节数|
|[Get](#get)|获取指定key的Meta值|
|[Set](#set)|设置指定key的Meta值|
|[CopyMeta](#copymeta)|拷贝指定Buffer的所有Meta值给新Buffer|
---

## 构造方法

构造新的Buffer。

```c++
    Buffer();
    Buffer(const std::shared_ptr<Device>& device, uint32_t dev_mem_flags = 0);
```

**args:**

* **device** (modelbox::Device) —— 构造当前Buffer所在的modelbox::Device对象
* **dev_mem_flags**  (uint32_t) —— 内存类型，ascend memory的类型时有效。

**return:**  

构造出来的新的Buffer。

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

构建出了和当前功能单元在同一个设备上面的Buffer对象

## Build

通过Buffer对象构建特定大小的内存。

```c++
    Status Build(size_t size);
    //data在device侧
    Status Build(void* data, size_t data_size,
                       DeleteFunction func = nullptr);
```

**args:**  

* **size** (size_t) —— Buffer申请的内存字节大小
* **data** (void*) 构建给Buffer管理的数据指针
* **data_size** (size_t) —— Buffer申请的内存字节大小
* **func** (DeleteFunction ) —— 释放Buffer指针的函数

## BuildFromHost

```c++
    // data在host侧
    Status BuildFromHost(void* data, size_t data_size,
                               DeleteFunction func = nullptr);
```

**args:**  

* **data** (void*) 构建给Buffer管理的数据指针
* **data_size** (size_t) —— Buffer申请的内存字节大小
* **func** (DeleteFunction ) —— 释放Buffer指针的函数

**return:**  

modelbox::Status, 构建Buffer的返回的status状态

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

构建成功了3个Buffer，通过不同的方式申请内存赋值

## ConstData

获取Buffer的原始数据的常量指针

**args:**  

无

**return:**  

const void*, 原始数据的常量指针

## MutableData

获取Buffer的原始数据的指针

**args:**  

无

**return:**  

void*, 原始数据的指针

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该功能单元为1输入1输出，输入端口名为input，输出端口名为output
        auto input_bufs = data->Input("input");
        auto output_bufs = data->Output("output");
        for (auto i = 0; i < input_bufs->Size(); ++i) {
            // 指定位置的Buffer
            auto buffer = input_bufs->At(i);
            // 数据原始指针
            const void* data1 = buffer->ConstData();
        }

        ...
        // output_bufs已经构建好了内存以及数据
        for (auto i = 0; i < output_bufs->Size(); ++i) {
            // 指定位置的Buffer
            auto buffer = output_bufs->At(i);
            void* data2 = buffer->MutableData();
        }
    }
        
```

**result:**

data1和data2为获取Buffer的数据指针

**note:**

1. input的BufferList当中获取数据用ConstData()接口，output的BufferList当中获取数据使用MutableData()接口

1. 功能单元当中的输入数据是为不可变，输出数据需要构造赋值，为可变。  

## HasError

判断当前Buffer是否存在处理异常

```c++
    bool HasError() const;
```

**args:**  

无

**return:**  

bool, 当前Buffer是否存在error

## SetError

设置当前Buffer处理异常信息

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

获取当前Buffer异常信息的错误码

```c++
    std::string GetErrorCode() const;
```

**args:**  

无

**return:**  

string, 当前Buffer的错误码

## GetErrorMsg

获取当前Buffer异常信息的错误信息

```c++
    std::string GetErrorMsg() const;
```

**args:**  

无

**return:**  

string, 当前Buffer的错误信息

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该功能单元为1输入1输出，输入端口名为input，输出端口名为output
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
        //假设该功能单元为1输入1输出，输入端口名为input，输出端口名为output
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

可以在报错时给Buffer设置error，然后在其他功能单元里面补充获取存在Bufferr的error_code和error_msg

## GetBytes

获取当前Buffer的字节数

```c++
    size_t GetBytes() const;
```

**args:**  

无

**return:**  

int64, Buffer的字节数

**example:**  

```c++
    
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        //假设该功能单元为1输入1输出，输入端口名为input，输出端口名为output
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

获取该Buffer的字节数

## Set

设置当前Buffer的某个Meta值

```c++
    template <typename T>
    void Set(const std::string& key, T&& value)
```

**args:**  

* **key** (str) —— Meta的key值

* **value** (template) —— Meta的value值

**return:**  

无

## Get

获取当前Buffer的某个Meta值

```c++
    template <typename T>
    bool Get(const std::string& key, T&& value)
```

**args:**  

* **key** (str) —— Meta的key值
* **value** (template) —— 接收Meta的value值

**return:**  

bool, 是否获取Meta值成功

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取Buffer中的指定Meta值
        auto input_bufs = data_ctx->Input("input");
        auto buffer = input_bufs->At(0);
        // 获取Buffer Meta当中的shape信息，res为get的结果
        std::vector<int> shape;
        auto res = buffer->Get("shape", shape);
        if (!res) {
            return STATUS_FAULT;
        }
        
        // 更新shape值后重新，设置到out_buffer的Meta当中
        auto output_bufs = data_ctx->Output("output");
        shape.push_back(1);
        auto out_buffer = output_bufs->At(0);
        out_buffer->Set("shape", shape);
    }
```

## CopyMeta

把参数的Buffer Meta信息拷贝给当前Buffer

```c++
    Status CopyMeta(const std::shared_ptr<Buffer> buf,
                          bool is_override = false)
```

**args:**  

* **buf** (modelbox::Buffer) —— Meta来源的Buffer
* **is_override** (bool) —— Meta是否需要覆盖

**return:**  

modelbox::Status  返回CopyMeta接口Status

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取Buffer中的指定Meta值
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
        auto buffer = input_bufs->At(0);
        output_bufs->Build({1});

        auto new_buffer = output_bufs->At(0);
        new_buffer->CopyMeta(buffer);
       
    }
        
```

**result:**

new_buffer具有和原始Buffer相同的Meta信息
