# modelbox.DataContext

每一个流单元当中存放数据上下文的所有接口

|函数|作用|
|-|-|
|[input](#modelboxdatacontextinput)|flowunit获取input端口的数据|
|[output](#modelboxdatacontextoutput)|flowunit获取output端口的数据|
|[has_error](#modelboxdatacontexthaserror)|datacontext当中是否存在error|
|[get_error](#modelboxdatacontextgeterror)|从datacontext中获取error|
|[set_private_string](#modelboxdatacontextsetprivateint)|设置datacontext中的私有字符串值|
|[get_private_string](#modelboxdatacontextgetprivatestring)|获取datacontext中的私有字符串值|
|[set_private_int](#modelboxdatacontextgetprivateint)|设置datacontext中的私有整型值|
|[get_private_int](#modelboxdatacontextgetprivateint)|获取datacontext中的私有整型值|
|[get_input_meta](#modelboxdatacontextgetinputmeta)|获取datacontext当中绑定在input端口的值|
|[set_output_meta](#modelboxdatacontextsetoutputmeta)|设置datacontext当中绑定在output端口的值|
|[get_session_config](#modelboxdatacontextgetsessionconfig)|获取datacontext当中的session config|
|[get_session_context](#modelboxdatacontextgetsessioncontext)|获取datacontext当中的session_context|
|[send_event](#modelboxdatacontextsendevent)|发送event|
---

## modelbox.DataContext.has_error

当前数据上下文是否存在error

**args:**  

无

**return:**  

bool 是否存在error

## modelbox.DataContext.get_error

获取当前数据上下文是否存在error

**args:**  

无

**return:**  

modelbox.FlowUnitError  获取当前数据上下文的error对象

**example:**  

```python
    ...
    def Process(self, data_ctx):
        if data_ctx.has_error():
           error = data_ctx.get_error()
           print(error.get_description(), type(error))
        ...
        
        return modelbox.Status()
        
```

**result:**  

> "error"  
> modelbox.FlowUnitError

## modelbox.DataContext.send_event

从当前数据上下文发送event给调度器

**args:**  

modelbox.FlowUnitEvent

**return:**  

无

**example:**  

```python
    ...
    def Process(self, data_ctx):
        event = modelbox.FlowUnitEvent()
        data_ctx.send_event(event)
        ...
        
        return modelbox.Status()
        
```

**result:**  

具体接口参见FlowUnitEvent

## modelbox.DataContext.set_private_string

设置当前数据上下文私有字符串值

**args:**  

* **key** (str)  —— 设置字符串型值得key

* **value** (str) ——  设置字符串型值的value

**return:**  

无

## modelbox.DataContext.get_private_string

获取当前数据上下文私有字符串值

**args:**  

* **key** (str)  ——  需要获取的字符串型的key

**return:**  

str  获取当前key值的字符串型value值

## modelbox.DataContext.set_private_int

设置当前数据上下文私有整型值

**args:**  

* **key** (str)  ——  设置整型值得key

* **value** (int) ——  设置整型值的value

**return:**  

无

## modelbox.DataContext.get_private_int

获取当前数据上下文私有整型值

**args:**  

* **key** (str)  ——  需要获取的整型的key

**return:**  

int  获取当前key值的整型value值

**example:**  

```python
    ...
    def Process(self, data_ctx):
        data_ctx.set_private_string("test", "test")
        print(data_ctx.get_private_string("test"))
        data_ctx.set_private_int("int", 33)
        print(data_ctx.get_private_int("int"))
        ...
        
        return modelbox.Status()
        
```

**result:**  

> "test"  
> 33

## modelbox.DataContext.input

flowunit获取input端口的数据

**args:**  

* **key** (str)  ——  input端口的名称

**return:**  

modelbox.BufferList  名称为key的input端口的数据的BufferList

## modelbox.DataContext.output

flowunit获取input端口的数据

**args:**  

* **key** (str)  ——  output端口的名称

**return:**  

modelbox.BufferList  名称为key的output端口的数据的BufferList

**example:**  

```python
    ...
    def Process(self, data_ctx):
        input_buf_list = data_ctx.input("input")
        output_buf_list = data_ctx.output("output")
        ...
        
        return modelbox.Status()
        
```

**result:**  

获取指定端口的数据bufferList, 注意input和output端口必须为当前流单元定义

## modelbox.DataContext.get_input_meta

获取当前数据上下文的input端口上面的meta值

**args:**  

* **key** (str)  ——  input端口名

**return:**  

modelbox.DataMeta  保存meta值得modelbox数据结构

## modelbox.DataContext.set_output_meta

设置当前数据上下文的output端口上面的meta值

**args:**  

* **key** (str)  ——  output端口名  

* **meta** (modelbox.DataMeta) ——  绑定在当前端口的DataMeta数据结构

**return:**  

modelbox.Status  设置的状态

**example:**  

```python
    ...
    def Process(self, data_ctx):
        input_meta = data_ctx.get_input_meta("input")
        res = data_ctx.set_output_meta("output", input_meta)
        ...
        
        return modelbox.Status()
        
```

**result:**  

获取input端口的meta和直接将该meta设置给output, modelbox.DataMeta参照data meta的接口

## modelbox.DataContext.get_session_config

获取当前数据上下文的session config

**args:**  

无

**return:**  

modelbox.SessionConfig

## modelbox.DataContext.get_session_context

获取当前数据上下文的session context

**args:**  

无

**return:**  

modelbox.SessionContext

**example:**  

```python
    ...
    def Process(self, data_ctx):
        session_config = data_ctx.get_session_config()
        session_context = data_ctx.get_session_context()
        ...
        
        return modelbox.Status()
        
```

**result:**  

具体接口参见session_config和session_context接口
