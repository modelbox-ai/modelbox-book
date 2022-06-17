# modelbox.Buffer

|函数|作用|
|-|-|
|[构造方法](#构造方法)| Buffer的构造方法|
|[as_object](#modelboxbufferasobject)|将ModelBox Buffer对象转换成Python对象|
|[copy_meta](#modelboxbuffercopymeta)|拷贝参数自带的所有Meta信息给当前Buffer|
|[has_error](#modelboxbufferhaserror)|判断当前Buffer是否存在处理异常|
|[get_error](#modelboxbuffergeterror)|获取当前Buffer的处理异常|
|[get_bytes](#modelboxbuffergetbytes)|获取当前Buffer的字节数|
|[get](#modelboxbufferget)|获取当前Buffer的某个Meta值|
|[set](#modelboxbufferset)|设置当前Buffer的某个Meta值|
---

## 构造方法

构造Buffer对象。

### modelbox.Buffer(device, data)

**args:**

* **device** (modelbox.Device) —— 构造当前Buffer所在的modelbox.Device对象
* **data**  (numpy.array) —— 当前Buffer包含的numpy数据

### modelbox.Buffer(device, string)

**args:**

* **device** (modelbox.Device) —— 构造当前Buffer所在的modelbox.Device对象
* **string**  (str) —— 当前Buffer包含的string数据

### modelbox.Buffer(device, list_item)

**args:**

* **device** (modelbox.Device) —— 构造当前Buffer所在的modelbox.Device对象
* **list_item**  (str) —— 当前Buffer包含的list数据，其中每一个元素必须同一类型

**return:**  

modelbox.Buffer

**example:**  

```python
   import numpy as np
   ...
   def process(self, data_ctx):
       infer_data = np.ones((5,5))
       numpy_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
       str_buffer = modelbox.Buffer(self.get_bind_device(), "test")
       list_buffer = modelbox.Buffer(self.get_bind_device(), [3.1, 3.2, 3.3])
       ...
    
   return modelbox.Status()
        
```

## modelbox.Buffer.as_object

将ModelBox Buffer对象自动转换成Python原始对象，如Buffer是由numpy类型转为而来，则调用as_object后返回numpy类型对象。目前支持基础类型、numpy.array、str类型。

**args:**  

无

**return:**  

基础类型、str 或者 numpy.array对象

**example:**  

```python
    ...
    def process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            data = buf.as_object()
            print(data, type(data))
            ...
        
        return modelbox.Status()
        
```

## modelbox.Buffer.has_error

判断当前Buffer是否存在处理异常。

**args:**  

无

**return:**  

bool, 是否存在处理异常

**example:**  

```python
    ...
    def process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            res = buf.has_error()
            ...
        
        return modelbox.Status()
        
```

## modelbox.Buffer.get_error

获取当前Buffer的第一个异常信息对象。

**args:**  

无

**return:**  

modelbox.FlowUnitError

**example:**  

```python
    ...
    def process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            error = buf.get_error()
            ...
        
        return modelbox.Status()
```

## modelbox.Buffer.get_bytes

获取当前Buffer的字节数

**args:**  

无

**return:**  

int64, Buffer的字节数

**example:**  

```python
    import numpy as np
    ...
    def process(self, data_ctx):
        infer_data = np.ones((5,5))
        new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
        bytes = new_buffer.get_bytes()
        print(bytes)
        ...
        
        return modelbox.Status()
        
```

**result:**

字节数为 5\*5\*8 = 200

## modelbox.Buffer.set

设置当前Buffer的某个Meta值

**args:**  

* **key** (str) —— Meta的key值

* **obj** (int, str, double, bool, modelbox.ModelBoxDataType, list[str], list[int], list[double], list[bool]) —— Meta的value值

**return:**  

bool, 是否设置成功

## modelbox.Buffer.get

获取当前Buffer的某个Meta值

**args:**  

* **key** (str) ——Meta的key值

**return:**  

Python object 获取key对应的value值

type: int, double, str, bool, list[int], list[str], list[double], list[bool]

**example:**  

```python
   ...
   def process(self, data_ctx):
        infer_data = np.ones((5,5))
        new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
        res = new_buffer.set("key", "test")
        print(res)
        print(new_buffer.get("key"))
        ...
        
        return modelbox.Status()
```

**result:**  

> true
> test

## modelbox.Buffer.copy_meta

把参数的Buffer的所有Meta信息拷贝给当前Buffer

**args:**  

* **buffer** (modelbox.Buffer) —— 源Buffer

**return:**  

modelbox.Status

**example:**  

```python
    import numpy as np
    ...
    def process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            infer_data = np.ones((5,5))
            new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
            #  new_buffer具有和buf相同的Meta信息
            status = new_buffer.copy_meta(buf)
            ...
        
        return modelbox.Status()
        
```
