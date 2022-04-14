# modelbox.DataContext

每一个流单元当中存放数据上下文的所有接口

|函数|作用|
|-|-|
|[Input](#input)|flowunit获取input端口的数据|
|[Output](#output)|flowunit获取output端口的数据|
|[External](#external)||
|[HasError](#haserror)|datacontext当中是否存在error|
|[SendEvent](#sendevent)|发送event|
|[SetPrivate](#setprivate)|设置datacontext中的私有Meta值|
|[GetPrivate](#getprivate)|获取datacontext中的私有Meta值|
|[GetInputMeta](#getinputmeta)|获取datacontext当中绑定在input端口的值||
|[SetOutputMeta](#setoutputmeta)|设置datacontext当中绑定在output端口的值|
|[GetSessionConfig](#getsessionconfig)|获取datacontext当中的session config|
|[GetSessionContext](#getsessioncontext)|获取datacontext当中的session_context|
|[GetStatistics](#getstatistics)|获取statistics对象|
---

## Input

flowunit获取input端口的数据

```c++
    std::shared_ptr<BufferListMap> Input() const;
    std::shared_ptr<BufferList> Input(const std::string &port);
```

## Output

flowunit获取output端口的数据

```c++
    std::shared_ptr<BufferListMap> Output() const;
    std::shared_ptr<BufferList> Output(const std::string &port);
```

**args:**  

* **port** (string) —— 输入端口名

**return:**  

modelbox::BufferListMap (map) —— 按照input port name存放BufferList的map

modelbox::BufferList (modelbox::BufferList) —— 存放对应input port的BufferList数据

* **example**

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 1个input，name为“input”; 1个output， name为“output”
        auto inputs = data_ctx->Input();
        auto outputs = data_ctx->Output();
        auto input = data_ctx->Input("input");
        auto output = data_ctx->Output("output");

    }
```

## External

获取datacontext绑定的从input端点传入的BufferList

```c++
    std::shared_ptr<BufferList> External();
```

**args:**  

无

**return:**  

modelbox::BufferList

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        // 1个input，name为“input”; 1个output， name为“output”
        auto input = data_ctx->External();
    }
```

## SendEvent

从当前数据上下文发送event给调度器可重新调度当前流单元

```c++
    void SendEvent(std::shared_ptr<FlowUnitEvent> event);
```

**args:**  

modelbox::FlowUnitEvent 可以参考FlowUnitEvent的说明和接口

**return:**  

无

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto event = std::make_shared<FlowUnitEvent>();
        data_ctx->SendEvent(event);
    }
```

**result:**  

具体接口参见FlowUnitEvent

## HasError

判断当前datacontext是否存在error

```c++
    bool HasError();
```

**args:**  

无

**return:**  

bool， 是否存在error

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto res = data_ctx->HasError();
    }
```

## SetPrivate

设置当前flowunit中保存在DataContext中的对象

```c++
    void SetPrivate(const std::string &key,
                          std::shared_ptr<void> private_content);
```

**args:**  

* **key** (string)  —— 设置对象的key值
* **private_content** (`shared_ptr<void>`) —— 设置对象的val的智能指针

**return:**  

无

## GetPrivate

获取当前flowunit中保存在DataContext中的对象

```c++
    std::shared_ptr<void> GetPrivate(const std::string &key);
```

**args:**  

* **key** (str)  ——  需要获取对象的key值

**return:**  

`shared_ptr<void>` key值对应的value的智能指正

**example:**  

```c++
    Status DataPre(std::shared_ptr<DataContext> data_ctx) {
        auto index_counter = std::make_shared<int64_t>(0);
        data_ctx->SetPrivate("index", index_counter);
    }

    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto index_counter = data_ctx->GetPrivate("index");
        MBLOG_INFO << *index_counter;
    }
```

**result:**  

> 0

## GetInputMeta

flowunit获取input端口的数据

```c++
    const std::shared_ptr<DataMeta> GetInputMeta(
      const std::string &port);
```

**args:**  

* **port** (string)  ——  input端口的名称

**return:**  

modelbox::DataMeta 端口的数据

## SetOutputMeta

flowunit获取input端口的数据

```c++
    void SetOutputMeta(const std::string &port,
                             std::shared_ptr<DataMeta> data_meta);
```

**args:**  

* **port** (string)  ——  output端口的名称
* **data_meta** (modelbox::DataMeta) —— 端口的数据，具体参见DataMeta

**return:**  

无

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto input_meta = data_ctx->GetInputMeta("input")
        data_ctx->SetOutputMeta("output", input_meta)
    }
        
```

**result:**  

获取input端口的meta和直接将该meta设置给output, modelbox::DataMeta参照data meta的接口

## GetSessionConfig

获取当前数据上下文的SessionConfig

```c++
    std::shared_ptr<Configuration> GetSessionConfig();
```

**args:**  

无

**return:**  

modelbox::Configuration

## GetSessionContext

获取当前数据上下文的SessionContext

```c++
    std::shared_ptr<SessionContext> GetSessionContext();
```

**args:**  

无

**return:**  

modelbox::SessionContext

## GetStatistics

获取当前数据上下文的Statistics

```c++
    std::shared_ptr<StatisticsItem> GetStatistics(
      DataContextStatsType type = DataContextStatsType::NODE);
```

**args:**

modelbox::DataContextStatsType, statistics的数据级别，具体参见StatisticsItem api

**example:**  

```c++
    ...
   Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto session_config = data_ctx->GetSessionConfig();
        auto session_context = data_ctx->GetSessionContext();
        auto statistics = data_ctx->GetStatistics();
        ...
        
        return STATUS_OK;
   }
        
```

**result:**  

具体接口参见session_context、statistics接口
