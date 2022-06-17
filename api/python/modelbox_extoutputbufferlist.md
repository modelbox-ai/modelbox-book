# modelbox.ExtOutputBufferList

|函数|作用|
|-|-|
|[get_buffer_list](#modelboxextoutputbufferlistgetbufferlist)|获取数据中的BufferList|
---

## modelbox.ExtOutputBufferList.get_buffer_list

获取指定端口的BufferList数据, 一般和externalDataMap一起使用。

**args:**  

无

**return:**  

modelbox.BufferList

**example:**  

```python
    ...
    import numpy as np

    img_np = np.ones((5,5))
    flow = modelbox.Flow()

    extern_data_map = flow.create_external_data_map()
    buffer_list = extern_data_map.create_buffer_list()
    buffer_list.push_back(img_np)
    extern_data_map.send("input1", buffer_list)
    extern_data_map.shutdown()
    
    buffer_list_map = modelbox.ExtOutputBufferList()
    ret = extern_data_map.recv(buffer_list_map)
    self.assertTrue(ret)
    # output1 为流程图中定义的output类型端口的端口名称
    result_buffer_list = buffer_list_map.get_buffer_list("output1")
    ...
        
```
