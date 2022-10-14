# modelbox::Flow

|函数|作用|
|-|-|
|[Init](#init)|初始化flow|
|[Build](#build)|构造flow|
|[Run](#run)|同步运行flow|
|[RunAsync](#runasync)|异步运行flow|
|[Wait](#wait)|等待流程图flow运行状态返回|
|[Stop](#stop)|停止flow|
|[CreateExternalDataMap](#createexternaldatamap) | 流程图flow创建输入的字典对象|
---

## Init

初始化flow

```c++
    enum Format {
        FORMAT_AUTO,
        FORMAT_TOML,
        FORMAT_JSON,
        FORMAT_UNKNOWN,
    };
```

支持流程图的类型

```c++
    Status Init(const std::string& configfile, Format format = FORMAT_AUTO);
```

**args:**  

* **configfile** (string) ——  流程图所在的路径位置
* **format** (Format) —— 流程图文件类型

**return:**  

modelbox::Status  初始化flow的返回状态

```c++
    Status Init(const std::string& name, const std::string& graph,
              Format format = FORMAT_AUTO);
```

**args:**  

* **name** (string) ——  流程图所在的名字
* **graph** (string) —— 流程图所在的路径位置
* **format** (Format) —— 流程图文件类型

**return:**  

modelbox::Status  初始化flow的返回状态

```c++
    Status Init(const Solution& solution);
```

**args:**  

* **solution** (solution) ——  解决方案对象，可以参考[Solution](../c++/modelbox_solution.md)

**return:**  

modelbox::Status  初始化流程图flow的返回状态

## Build

构建flow

```c++
    Status Build();
```

**args:**  

无

**return:**  

modelbox::Status 构造流程图flow的返回状态

## RegisterFlowUnit

注册内联功能单元

```c++
    void RegisterFlowUnit(const std::shared_ptr<modelbox::FlowUnitBuilder>& flowunit_builder);
```

**args:**  

* **flowunit_builder** (FlowUnitBuilder) ——  功能单元工厂类。

**return:**  

无

## Run

同步运行flow，阻塞直至运行结束

```c++
    Status Run();
```

**args:**  

无

**return:**  

modelbox::Status 同步运行流程图flow的返回状态

## RunAsync

异步运行flow

```c++
    Status RunAsync();
```

**args:**  

无

**return:**  

modelbox::Status 异步运行流程图flow的返回状态

## Stop

停止flow

```c++
    Status Stop();
```

**args:**  

无

**return:**  

modelbox::Status 停止运行流程图flow的返回状态

## Wait

等待flow运行结束

```c++
    Status Wait(int64_t millisecond = 0, Status* ret_val = nullptr);
```

**args:**  

* **millisecond** (int64_t) ——  等待的超时时间，毫秒
* **ret_val** (Status*) —— 流程图的运行结果

**return:**  

modelbox::Status 等待流程图flow运行结束的返回状态

**example:**  

```c++
    #include <modelbox/flow.h>

    int main() {
        string conf_file = "test.toml";
        bool async = true;
        auto flow = std::make_shared<Flow>();
        auto status = flow->Init(conf_file);

        // init method 2
        {   
            auto flow2 = std::make_shared<Flow>(); 
            auto status = flow2->Init("test_graph", conf_file);
        }

        // init method 3
        {
            auto flow3 = std::make_shared<Flow>(); 
            Solution solution("solution_name");
            auto status = flow3->Init(solution);
        }

        status = flow->Build();
        if (async) {
            status = flow->RunAsync();
        } else {
            status = flow->Run();
        }

        Status retval;
        status = flow->Wait(1000 * 3, &retval);
        status = flow->Stop();

        return 0;
    }

```

## CreateExternalDataMap

创建流程图的输入数据的数据结构

```c++
    std::shared_ptr<ExternalDataMap> CreateExternalDataMap();
```

**args:**  

无

**return:**  

modelbox::ExternalDataMap 存储输入数据的数据结构, 参考[ExternalDataMap](../c++/modelbox_externaldatamap.md)

**example:**  

```c++
    #include <modelbox/flow.h>

    int main() {
        auto flow = std::make_shared<Flow>();
        auto external_map = flow->CreateExternalDataMap();
        ...
        return 0;
    }
```
