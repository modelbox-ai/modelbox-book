# modelbox.ExternalDataMap

|函数|作用|
|-|-|
|[create_buffer_list](#modelboxexternaldatamapcreatebufferlist)|创建BufferList|
|[send](#modelboxexternaldatamapsend)|发送BufferList给当前流程图|
|[recv](#modelboxexternaldatamaprecv)|接收给当前流程图处理结果|
|[close](#modelboxexternaldatamapclose)|关闭当前external_data_map的输入|
|[shutdown](#modelboxexternaldatamapshutdown)|强制关闭当前external_data_map的连接|
|[set_output_meta](#modelboxexternaldatamapsetoutputmeta)|设置external_data_map中的输出端口的meta值|
---

## modelbox.ExternalDataMap.create_buffer_list

创建BufferList。

**args:**  

无

**return:**  

modelbox.BufferList

## modelbox.ExternalDataMap.send

发送BufferList给流程图中的输入端口。

**args:**  

* **port_name** (str) ——  需要发送的数据的端口名

* **bufferlist** (modelbox.BufferList) ——  需要发送的BufferList

**return:**  

modelbox.Status  

## modelbox.ExternalDataMap.recv

接收给当前流程图处理结果。

**args:**  

* **bufferlist** (modelbox.ExtOutputBufferList) ——  用来接收数据的BufferList

**return:**  

modelbox.Status  

## modelbox.ExternalDataMap.close

关闭当前external_data_map的输入，表示数据输入结束

**args:**  

无

**return:**  

modelbox.Status  

## modelbox.ExternalDataMap.shutdown

强制关闭当前ExternalDataMap对象的状态

**args:**  

无

**return:**  

modelbox.Status  

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
    # input1 为流程图中定义的input类型端口的端口名称
    ret = extern_data_map.send("input1", buffer_list)
    ret = extern_data_map.close()
    
    buffer_list_map = modelbox.ExtOutputBufferList()
    ret = extern_data_map.recv(buffer_list_map)

    ret = extern_data_map.shutdown()    
```

```toml
   digraph demo {                                                                            
    input1[type=input]   
    python_buffer[type=flowunit, flowunit=python_buffer, device=cpu, deviceid=0]  
    output1[type=output]   
    input1 -> python_buffer:buffer_in
    python_buffer:buffer_out -> output1                                                                                             
   }
```

## modelbox.ExternalDataMap.set_output_meta

设置外部数据输出端口的Meta值。

**args:**  

* **port_name** (str) —— 输出的端口名字

* **meta** (modelbox.DataMeta) —— 存放Meta的数据结构

**return:**  

modelbox.Status
