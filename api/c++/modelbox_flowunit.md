# modelbox::FlowUnit

|函数|作用|
|-|-|
|[Open](#open)|功能单元初始化逻辑|
|[Process](#process)|功能单元处理逻辑|
|[Close](#close)|功能单元关闭逻辑|
|[DataPre](#datapre)|Stream流初始化逻辑|
|[DataPost](#datapost)|Stream流结束逻辑|
|[GetBindDevice](#getbinddevice)|获取功能单元绑定的设备|
---

## Open

功能单元初始化逻辑

**args:**  

* **config** (modelbox::Configuration) ——  流程图当中配给当前功能单元的配置项

**return:**  

modelbox::Status  初始化功能单元的返回状态

## Process

功能单元处理逻辑

**args:**  

* **data_context**  (modelbox::DataContext) ——  处理逻辑当中存放数据的上下文

**return:**  

modelbox::Status 功能单元处理逻辑的返回状态

## Close

功能单元结束逻辑

**args:**  

无

**return:**  

modelbox::Status 功能单元结束逻辑的返回状态

## DataPre

Stream流初始化逻辑

**args:**  

* **data_context**  (modelbox::DataContext) ——  初始化Stream逻辑当中存放数据的上下文

**return:**  

modelbox::Status 初始化Stream时的逻辑的返回状态

## DataPost

Stream流结束逻辑

**args:**  

* **data_context**  (modelbox::DataContext) ——  结束Stream逻辑当中存放数据的上下文

**return:**  

modelbox::Status 结束Stream逻辑的返回状态

```c++
    /**
     * @brief Flowunit open function, called when unit is open for processing data
     * @param config flowunit configuration
     * @return open result
     */
    Status Open(const std::shared_ptr<Configuration> &config);

    /**
     * @brief Flowunit close function, called when unit is closed.
     * @return open result
     */
    Status Close();

    /**
     * @brief Flowunit data process.
     * @param data_ctx data context.
     * @return open result
     */
    Status Process(std::shared_ptr<DataContext> data_ctx);

    /**
     * @brief Flowunit data pre.
     * @param data_ctx data context.
     * @return data pre result
     */
    Status DataPre(std::shared_ptr<DataContext> data_ctx);

    /**
     * @brief Flowunit data post.
     * @param data_ctx data context.
     * @return data post result
     */
    Status DataPost(std::shared_ptr<DataContext> data_ctx);
```

**example:**  

```c++
   ...
   # 典型flowunit场景
   modelbox::Status VideoDecoderFlowUnit::Open(
    const std::shared_ptr<modelbox::Configuration> &opts) {
        out_pix_fmt_str_ = opts->GetString("pix_fmt", "nv12");
        ...

        return modelbox::STATUS_OK;
    }

    modelbox::Status VideoDecoderFlowUnit::Close() { return modelbox::STATUS_OK; }

    modelbox::Status VideoDecoderFlowUnit::Process(
        std::shared_ptr<modelbox::DataContext> ctx) {
        auto input_bufs = ctx->Input("in_video_packet");
        auto output_bufs = ctx->Output("out_video_frame");
        ...

        return modelbox::STATUS_CONTINUE;
    }

    modelbox::Status VideoDecoderFlowUnit::DataPre(
    std::shared_ptr<modelbox::DataContext> data_ctx) {
        MBLOG_INFO << "Video Decode Start";
        auto in_meta = data_ctx->GetInputMeta(VIDEO_PACKET_INPUT);
        ...
        return modelbox::STATUS_OK;
    }

    modelbox::Status VideoDecoderFlowUnit::DataPost(
        std::shared_ptr<modelbox::DataContext> data_ctx) {
        return modelbox::STATUS_OK;
    }
        
```

## GetBindDevice

获取当前功能单元绑定设备

**args:**  

无

**return:**  

modelbox::Device, 当前绑定设备

**example:**  

```c++
   ...
   modelbox::Status VideoDecoderFlowUnit::Process(
        std::shared_ptr<modelbox::DataContext> ctx) {
        auto device = GetBindDevice();
        ...

        return modelbox::STATUS_OK;
   }
```
