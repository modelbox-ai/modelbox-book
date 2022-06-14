# modelbox.ExternalDataMap

|函数|作用|
|-|-|
|[create_buffer_list](#modelboxexternaldatamapcreatebufferlist)|创建BufferList|
|[send](#modelboxexternaldatamapsend)|发送给当前flow对象的BufferList|
|[recv](#modelboxexternaldatamaprecv)|接收给当前flow对象的BufferList|
|[shutdown](#modelboxexternaldatamapshutdown)|关闭当前external_data_map的连接|
|[set_output_meta](#modelboxexternaldatamapsetoutputmeta)|设置external_data_map中的输出端口的meta值|
---

## modelbox.ExternalDataMap.create_buffer_list

创建BufferList

**args:**  

无

**return:**  

modelbox.BufferList

## modelbox.ExternalDataMap.send

发送BufferList给下一个流单元

**args:**  

* **port_name** (str) ——  需要发送的数据的端口名

* **bufferlist** (modelbox.BufferList) ——  需要发送的BufferList

**return:**  

modelbox.Status  发送的返回状态

## modelbox.ExternalDataMap.recv

在参数的output_bufferlist接收数据

**args:**  

* **bufferlist** (modelbox.ExtOutputBufferList) ——  用来接收数据的BufferList

**return:**  

modelbox.Status  发送的返回状态

## modelbox.ExternalDataMap.shutdown

关闭external data map对象

**args:**  

无

**return:**  

modelbox.Status  

关闭的返回状态

**example:**  

```python
    ...
    import modelbox
    import numpy as np

    flow = modelbox.Flow()

    img_np = np.ones((5,5))
    extern_data_map = flow.create_external_data_map()
    buffer_list = extern_data_map.create_buffer_list()
    buffer_list.push_back(img_np)
    ret = extern_data_map.send("input1", buffer_list)
    ret = extern_data_map.shutdown()
    
    buffer_list_map = modelbox.ExtOutputBufferList()
    ret = extern_data_map.recv(buffer_list_map)
        
```

```toml
   digraph demo {                                                                            
    input1[type=input]   
    python_buffer[type=flowunit, flowunit=python_buffer, device=cpu, deviceid=0, label="<buffer_in> | <buffer_out>", buffer_config = 0.2]  
    output1[type=output]   
    input1 -> python_buffer:buffer_in
    python_buffer:buffer_out -> output1                                                                                             
   }
```

**result:**  

在定义的流程图中从input1输入数据

## modelbox.ExternalDataMap.set_output_meta

设置输出端口的meta值

**args:**  

* **port_name** (str) —— 输出的端口名字

* **meta** (modelbox.DataMeta) —— 存放meta的数据结构

**return:**  

modelbox.Status  返回状态
