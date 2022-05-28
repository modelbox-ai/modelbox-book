# 流单元上下文

流单元上下文可以分为`DataContext` 和 `SessionContext` 两种。

## DataContext

DataContext是流单元当中存储数据上下文的数据结构，具体结构参考[api](../../api/c++/modelbox_datacontext.md)

### 获取输入以及输出数据

通过Input， Output接口获取输入以及输出数据

```c++
    Status ExampleFlowUnit::Process(std::shared_ptr<DataContext> data_ctx) {
        // 该flowunit为1输入1输出，端口号名字分别为input, output
        auto input_bufs = data_ctx->Input("input");
        auto output_bufs = data_ctx->Output("output");

    }
```

### 获取上一次流单元处理存在data_ctx中的private数据以及设置要传入给下一次处理的private数据

通过GetPrivate, SetPrivate接口获取当前stream单元在DataPre中的定义对象

```c++
    modelbox::Status VideoDecoderFlowUnit::DataPre(
    std::shared_ptr<modelbox::DataContext> data_ctx) {
        // 获取Stream流元数据信息
        auto stream_meta = data_ctx->GetInputMeta("Stream-Meta");

        // 初始化Stream流数据处理上下文对象。
        auto decoder = CreateDecoder(stream_meta);

        // 保存流数据处理上下文对象。
        data_ctx->SetPrivate("Decoder", decoder);
        return modelbox::STATUS_OK;
        }

    modelbox::Status CVResizeFlowUnit::Process(
        std::shared_ptr<modelbox::DataContext> ctx) {
        // 获取流数据处理上下文对象。
        auto decoder = data_ctx->GetPrivate("Decoder");
        auto inputs = ctx->Input("input");
        auto outputs = ctx->Output("output");

        // 处理输入数据。
        decoder->Decode(inputs, outputs);

        return modelbox::STATUS_OK;
    }

    modelbox::Status VideoDecoderFlowUnit::DataPost(
        std::shared_ptr<modelbox::DataContext> data_ctx) {
        // 关闭解码器。
        auto decoder = data_ctx->GetPrivate("Decoder");
        decoder->DestroyDecoder();
        return modelbox::STATUS_OK;
    }
```

### 获取输入端口的meta和设置输出端口的meta

```c++
    modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<DataContext> data_ctx) {
        auto input_meta = data_ctx->GetInputMeta("input");
        data_ctx->SetOutputMeta("output", input_meta);
    }
```

### 判断DataContext当中是否存在error

```c++
    modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<DataContext> data_ctx) {
        auto res = data_ctx->HasError();
    }
```

### 通过DataContext发送event

在写自定义流单元当中，存在通过单数据驱动一次，process继续自驱动的场景，此时需要通过在流单元东中发送event继续驱动调度器在没有数据的情况下调度该流单元

```c++
    modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<DataContext> data_ctx) {
        ...
        auto event = std::make_shared<FlowUnitEvent>();
        data_ctx->SendEvent(event);
        return STATUS_CONTINUE;
    }
```

### 获取DataContext当中其他组件

可以参考DataContext [api](../../api/c++/modelbox_datacontext.md)

## SessionContext

存储当前stream中的全局变量， 具体可以参见[api](../../api/c++/modelbox_sessioncontext.md)

### 获取存在SessionContext中的全局数据以及设置全局数据

```c++
    modelbox::Status ExampleFlowUnit1::Process(std::shared_ptr<DataContext> data_ctx) {
        auto session_cxt = data_ctx->GetSessionContext();
        session_cxt->SetPrivate("http_limiter_" + session_cxt->GetSessionId(),
                          http_limiter);
    }
```

```c++
     modelbox::Status ExampleFlowUnit2::Process(std::shared_ptr<DataContext> data_ctx) {
        auto session_cxt = data_ctx->GetSessionContext();
        auto http_limiter = session_cxt->GetPrivate("http_limiter_" + session_cxt->GetSessionId());
    }
```
