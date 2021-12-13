# modelbox.BufferList

|函数|作用|
|-|-|
|[build](#modelboxbufferlistbuild)|bufferlist对象申请指定长度大小的内存空间|
|[copy_meta](#modelboxbufferlistcopymeta)|拷贝参数自带的所有meta信息给当前bufferlist|
|[get_bytes](#modelboxbufferlistget_bytes)|获取当前bufferlist的字节大小|
|[push_back](#modelboxbufferlistpush_back)|将一个buffer插入到当前的bufferlist当中|
|[set](#modelboxbufferlistset)|设置当前bufferlist的某个meta值|
|[size](#modelboxbufferlistsize)|获取当前bufferlist的长度|
|[len](#modelboxbufferlistsize)|可以被len函数获取当前bufferlist的长度|
|[构造方法](#构造方法)| bufferlist的构造方法|
---

## 构造方法

BufferList申请内存空间

### modelbox.BufferList()

**args:**  

无

### modelbox.BufferList(device)

**args:**  

* **device** (modelbox.Device) —— 构造当前buffer所在的modelbox.Device对象

### modelbox.BufferList(buffer)

**args:**

* **buffer** (modelbox.Buffer) —— 通过buffer构建bufferList

### modelbox.BufferList(buffer_list)

**args:**

* **buffer_list** (list[modelbox.Buffer]) —— 一组buffer

**return:**  

modelbox.BufferList

**example:**  

```python
    ...
    def Process(self, data_ctx):
        inputbuf_list = data_ctx.input("input")
        outputbuf_list = data_ctx.output("output")
        ...
        
        return modelbox.Status()
        
```

**result:**  

inputbuf_list和output_buf_list均为构建好的bufferlist，一般而言并不需要用户构建bufferlist

## modelbox.BufferList.build

BufferList申请内存空间

**args:**  

* **sizes** (list[int]) —— buffer_list当中每一个buffer的大小

**return:**  

modelbox.Status 申请结果的状态

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.output("output")
        res = buf_list.build([20, 20, 20])
        print(res, buf_list.size())
        for buf in buf_list:
            print(buf.get_bytes())
        ...
        
        return modelbox.Status()
        
```

**result:**

> true, 3  
> 20  
> 20  
> 20

## modelbox.BufferList.copy_meta

把参数的bufferlist里面的meta信息，copy给当前的bufferlist，一对一拷贝

**args:**  

* **buffer_list** (modelbox.BufferList) —— meta来源的bufferlist

**return:**  

modelbox.Status

**example:**  

```python
    ...
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("input")
        output_bufs = data_ctx.output("output")
        input_bytes = []
        for buf in input_bufs:
            input_bytes.append(buf.get_bytes())
        output_bufs.build(input_bytes)
        res = output_bufs.copy_meta(input_bufs)
        ...
        
        return modelbox.Status()
        
```

**result:**

output_bufs具有和原始input_bufs相同的meta信息

## modelbox.BufferList.get_bytes

获取BufferList中的所有的字节数

**args:**  

无

**return:**  

uint64

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.output("output")
        buf_list.build([20,20,20])
        print(buf_list.get_bytes())
        ...
        
        return modelbox.Status()
        
```

**result:**

> 60

## modelbox.BufferList.push_back

往bufferlist当中插入一个新的buffer

**args:**  

* **buffer** (modelbox.Buffer) —— 需要插入到bufferlist当中的buffer

**return:**  

无

**example:**  

```python
   import numpy as np
   ...
   def Process(self, data_ctx):
       buf_list = data_ctx.output("output")
       infer_data = np.ones((5,5))
       new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
       buf_list.push_back(new_buffer)
       ...

       return modelbox.Status()
        
```

**result:**  

buf_list当中的第一个buffer即为新建的buffer

## modelbox.BufferList.size

获取当前bufferlist的长度

**args:**  

无

**return:**  

modelbox.Bufferlist的长度

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.output("output")
        buf_list.build([20,20,20])
        size = buf_list.size()
        length = len(buf_list)
        print(size)
        print(length)
        for buf in buf_list:
            print(buf.get_bytes())
        ...
        
        return modelbox.Status()
        
```

**result:**

> 3  
> 3  
> 20  
> 20  
> 20

## modelbox.BufferList.set

设置当前bufferlist的某个meta值

**args:**  

* **key** (str) ——  meta的key值

* **obj** (int, str, double, bool, modelbox.ModelBoxDataType, list[str], list[int], list[double], list[bool]) ——  meta的value值

**return:**  

无

**example:**  

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.output("output")
        for i in range(3):
            infer_data = np.ones((5,5))
            new_buffer = modelbox.Buffer(self.get_bind_device(), infer_data)
            buf_list.push_back(new_buffer)
        
        res = buf_list.set("test", "test")
        print(res)
        for buf in buf_list:
            print(buf.get("test"))
        ...
        
        return modelbox.Status()
        
```

**result:**

> true  
> test  
> test  
> test
