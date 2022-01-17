# modelbox.ExtOutputBufferList

|函数|作用|
|-|-|
|[get_buffer_list](#modelboxextoutputbufferlistgetbufferlist)|设置datameta中的私有字符串值|
---

## modelbox.ExtOutputBufferList.get_buffer_list

获取当前device id

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

    result_buffer_list = buffer_list_map.get_buffer_list("output1")
    ...
        
```

**result:**  

获取指定端口的数据(bufferlist), 一般和externalDataMap一起使用
