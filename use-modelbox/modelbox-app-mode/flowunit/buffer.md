<!-- toc -->

# 流单元数据处理

这是编写自定义流单元当中处理数据的部分的说明

## buffer/buffer_list接口的使用场景

真正需要使用buffer/buffer_list接口是在编写自定义流单元当中需要处理数据时

### 流单元输入数据的获取

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 该flowunit为1输入1输出，端口号名字分别为input, output
        auto input_bufs = data_ctx->Input("input");
        for (auto i = 0; i < input_bufs->Size(); ++i) {
            // 指定位置的buffer
            auto buffer = input_bufs->At(i);
            // 数据原始指针
            const void* data1 = buffer->ConstData();
            // 该buffer的字节数
            auto bytes = buffer->GetBytes();
            // 通过buffer_list访问特定位置的数据指针，data1和data2是同一个指针
            void* data2 = input_bufs->ConstBufferData(i);
            ...
        }

    }
```

### 处理好的数据给输出buffer

这里可以分成一下三种情况

#### 输入的buffer直接塞给输出，不做数据本身的改变，如图片数据透传流单元

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 该flowunit为1输入1输出，端口号名字分别为input, output
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs =  data_ctx->Output("output");
        for (auto &buf: input_bufs) {
            output_bufs->PushBack(buf);
        }
        return STATUS_OK;
    }
```

#### 构建需要将控制权转给output_buffer_list的数据指针

```c++
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

#### 构建新的output_buffer_list, 取出每个buffer的数据进行处理

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto output_bufs = data_ctx->Output("output");
        ...
        //通过构建好buffer_list所有的size的大小，构造一个3个buffer的buffer_list，每个大小为1
        output_bufs->Build({1,1,1});

        //从host侧构建数据
        vector<size_t> shape{1,1,1};
        vector<uint8_t> data{122,123,124}
        output_bufs->BuildFromHost(shape, data.data(), 12);
        //获取第n个buffer
        for (auto i = 0; i < output_bufs->Size(); ++i ) { 
            auto buffer1 = output_bufs->At(0);
            //process buffer data
            ...
        }
        ...
    }
```

### buffer中获取传递来的属性(meta)值

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

### buffer的error接口

```c++
    // set error
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto output_bufs = data_ctx->Output("output");
        output_bufs->Build({1});

        bool error = true;
        if (error) {
            buffer->SetError("Sample.FAILED_001", "test error");
            output_bufs->PushBack(buffer);
        }
        ...
    }

    // get error
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Output("input");
        for (auto i = 0; i < input_bufs->Size(); ++i) {
            auto buffer = input_bufs->At(i);
            if (buffer->HasError()) {
                auto err_code = buffer->GetErrorCode();
                auto err_msg = buffer->GetErrorMsg();
            }
        }
        ...
    }
```

### buffer的其他可能接口以及用法

#### buffer的copy接口

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto buffer = input_bufs->At(0);
        auto new_buffer = buffer->Copy();
        auto new_deep_buffer = buffer->DeepCopy();
       
    }
```

#### buffer的copy所有meta值接口

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 获取buffer中的指定meta值
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");
        auto buffer = input_bufs->At(0);
        output_bufs->Build({1});

        auto out_buffer = output_bufs->At(0);
        out_buffer->CopyMeta(buffer);
       
    }
```
