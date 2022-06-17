# modelbox::FlowUnitDesc

描述功能单元描述信息的数据结构

|函数|作用|
|-|-|
|[SetFlowUnitName](#setflowunitname)|设置功能单元名字|
|[SetDescription](#setdescription)|设置功能单元描述|
|[SetFlowUnitGroupType](#setflowunitgrouptype)|设置功能单元组类型|
|[AddFlowUnitInput](#addflowunitinput)|给功能单元添加输入|
|[AddFlowUnitOutput](#addflowunitoutput)|给功能单元添加输出|
|[AddFlowUnitOption](#addflowunitoption)|给功能单元添加配置项|
|[SetFlowType](#setflowtype)| 设置功能单元数据处理类型|
|[SetOutputType](#setoutputtype)|设置功能单元输入类型|
|[SetConditionType](#setconditiontype)|设置功能单元条件类型|
|[SetInputContiguous](#setinputcontiguous)|设置功能单元输入是否连续|
|[SetExceptionVisible](#setexceptionvisible)|设置功能单元异常是否可见|
---

## SetFlowUnitName

```c++
     void SetFlowUnitName(const std::string &flowunit_name);
```

**args:**

* **flowunit_name** (string) —— 功能单元的名字

**return:**  

无

## SetDescription

```c++
     void SetDescription(const std::string &description)
```

**args:**

* **description** (string) —— 功能单元的详细描述

**return:**  

无

## SetFlowUnitGroupType

```c++
     void SetFlowUnitGroupType(const std::string &group_type)
```

**args:**

* **group_type** (string) —— 功能单元的组类型，限制为智能a-z, A-Z, 0-9, _，只允许存在一个/, 已有的group_type为“Image"等等

**return:**  

无，非必须， 默认为"generic"

## AddFlowUnitInput

```c++
     Status AddFlowUnitInput(const FlowUnitInput &flowunit_input);
```

**args:**

* **flowunit_input** (modelbox::FlowUnitInput) —— flowunit input对象， 参考[flowunit_input](modelbox_flowunitport.md)

**return:**  

modelbox::Status, 添加flowunit input返回的status状态

## AddFlowUnitOutput

```c++
     Status AddFlowUnitOutput(const FlowUnitOutput &flowunit_output);
```

**args:**

* **flowunit_output** (modelbox::FlowUnitOutput) —— flowunit output对象， 参考[flowunit_output](modelbox_flowunitport.md)

**return:**  

modelbox::Status, 添加flowunit output返回的status状态

## AddFlowUnitOption

```c++
     Status AddFlowUnitOption(const FlowUnitOption &flowunit_option);
```

**args:**

* **flowunit_option** (modelbox::FlowUnitOption) —— flowunit option对象， 参考[flowunit_option](modelbox_flowunitport.md)

**return:**  

modelbox::Status, 添加flowunit option返回的status状态

## SetFlowType

```c++
     void SetFlowType(FlowType flow_type);
```

**args:**

* **flow_type** (FlowType) —— 数据处理的 type， 分为NORMAL和STREAM

**return:**  

无, 默认为NORMAL

## SetOutputType

```c++
     void SetOutputType(FlowOutputType output_type)
```

**args:**

* **output_type** (FlowOutputType) —— 数据输出type， 分为ORIGIN, EXPAND, COLLAPSE

**return:**  

无

## SetConditionType

```c++
     void SetConditionType(ConditionType condition_type)
```

**args:**

* **condition_type** (ConditionType) —— 功能单元条件type， 分为IF_ELSE, NONE

**return:**  

无

**note:**

1. 上述3个接口共同确认功能单元为五种类型，分别为NORMAL, STREAM, IF_ELSE, EXPAND, COLLAPSE
1. 只需要设置某个特定接口即可
1. 五种flowunit设置样例如下：

```c++
    MODELBOX_FLOWUNIT(HTTPServerAsync, desc) {
        ...
        // 1. NORMAL
        desc.SetFlowType(modelbox::NORMAL);
        
        // 2. STREAM
        desc.SetFlowType(modelbox::STREAM);

        // 3. IF_ELSE
        desc.SetConditionType(modelbox::IF_ELSE);

        // 4. EXPAND
        desc.SetOutputType(modelbox::EXPAND);

        // 5. COLLAPSE
        desc.SetOutputType(modelbox::COLLAPSE);
        ...
    }
```

## SetInputContiguous

```c++
     void SetInputContiguous(bool is_input_contiguous)
```

**args:**

* **is_input_contiguous** (bool) —— 输入内存是否连续

**return:**  

无, 默认为true

## SetExceptionVisible

```c++
     void SetExceptionVisible(bool is_exception_visible)
```

**args:**

* **is_exception_visible** (bool) —— 异常是否可见

**return:**  

无, 默认为false

**example:**

```c++
    MODELBOX_FLOWUNIT(HTTPServerAsync, desc) {
        desc.SetFlowUnitName(FLOWUNIT_NAME);
        desc.AddFlowUnitOutput({"out_request_info"});
        desc.SetFlowType(modelbox::NORMAL);
        desc.SetFlowUnitGroupType("Input");
        desc.SetDescription(FLOWUNIT_DESC);
        desc.SetInputContiguous(false);
        desc.SetExceptionVisible(true);
        desc.AddFlowUnitOption(modelbox::FlowUnitOption("endpoint", "string", true,
                                                        "https://127.0.0.1:8080",
                                                        "http server listen URL."));
        desc.AddFlowUnitOption(modelbox::FlowUnitOption(
            "max_requests", "integer", true, "1000", "max http request."));
        desc.AddFlowUnitOption(
            modelbox::FlowUnitOption("keepalive_timeout_sec", "integer", false, "200",
                                    "keep-alive timeout time(sec)"));
        desc.AddFlowUnitOption(
            modelbox::FlowUnitOption("cert", "string", false, "", "cert file path"));
        desc.AddFlowUnitOption(
            modelbox::FlowUnitOption("key", "string", false, "", "key file path"));
        desc.AddFlowUnitOption(modelbox::FlowUnitOption(
            "passwd", "string", false, "", "encrypted key file password."));
        desc.AddFlowUnitOption(modelbox::FlowUnitOption(
            "key_pass", "string", false, "", "key for encrypted password."));
        
    }
```

**result:**

设置了插件的属性值
