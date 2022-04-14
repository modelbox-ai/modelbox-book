# modelbox.Buffer

|函数|作用|
|-|-|
|[as_object](#modelboxbufferasobject)|将ModelBox Buffer对象转换成Python对象|
|[copy_meta](#modelboxbuffercopymeta)|拷贝参数自带的所有Meta信息给当前Buffer|
|[has_error](#modelboxbufferhaserror)|判断当前Buffer是否存在error|
|[get_error](#modelboxbuffergeterror)|获取当前Buffer的error|
|[get_bytes](#modelboxbuffergetbytes)|获取当前Buffer的字节数|
|[get](#modelboxbufferget)|获取当前Buffer的某个Meta值|
|[set](#modelboxbufferset)|设置当前Buffer的某个Meta值|
|[构造方法](#构造方法)| Buffer的构造方法|
---

## 构造方法

把参数的Buffer的Meta信息 copy给当前Buffer

### modelbox.Buffer(device, data)

**args:**(建议args改为中文参数说明，建议用表格列举，参数名，类型，描述说明)

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

**return:**  返回值

modelbox.Buffer

**example:**  

```python
   import numpy as np
   ...
   def Process(self, data_ctx):
       infer_data = np.ones((5,5))
       numpy_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
       str_buffer = modelbox.Buffer(self.get_bind_device(), "test")
       list_buffer = modelbox.Buffer(self.get_bind_device(), [3.1, 3.2, 3.3])
       ...
    
   return modelbox.Status()
        
```

**result:**

new_buffer具有和原始Buffer相同的Meta信息

## modelbox.Buffer.as_object

将modelbox buffer object 转换成Python对象(可以转换成numpy array和str对象)

**args:**  

无

**return:**  

str 或者 numpy.array对象

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            data = buf.as_object()
            print(data, type(data))
            ...
        
        return modelbox.Status()
        
```

**result:**  

```python
    # 在demo mnist 当中mnist_preprocess的结果为(str)
    {"image_base64": "iVBORw0..."} <class 'str'>
    # 在test Python当中的Python_show flowunit中结果为(numpy.ndarray)
    [ 3  5  6 ...,  3  6 13] <class 'numpy.ndarray'>

```

## modelbox.Buffer.has_error

判断当前Buffer是否存在error

**args:**  

无

**return:**  

bool, 是否存在error

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            res = buf.has_error()
            ...
        
        return modelbox.Status()
        
```

**result:**

buf是否有error

## modelbox.Buffer.get_error

**args:**  

无

**return:**  

modelbox.FlowUnitError， 具体参见FlowUnitError章节

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            error = buf.get_error()
            ...
        
        return modelbox.Status()
```

**result:**

获得一个FlowUnitError对象

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
    def Process(self, data_ctx):
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
   def Process(self, data_ctx):
        infer_data = np.ones((5,5))
        new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
        res = new_buffer.set("test", "test")
        print(test)
        print(new_buffer.get("test"))
        ...
        
        return modelbox.Status()
```

**result:**  

> True  
> 'test'

## modelbox.Buffer.copy_meta

把参数的Buffer的Meta信息 copy给当前Buffer

**args:**  

* **buffer** (modelbox.Buffer) —— Meta来源的Buffer

**return:**  

modelbox.Status  返回copy_meta接口Status

**example:**  

```python
    import numpy as np
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            infer_data = np.ones((5,5))
            new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
            status = new_buffer.copy_meta(buf)
            ...
        
        return modelbox.Status()
        
```

**result:**

new_buffer具有和原始Buffer相同的Meta信息
