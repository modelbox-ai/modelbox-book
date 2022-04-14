# modelbox.ExternalDataMap

|函数|作用|
|-|-|
|[CreateBufferList](#CreateBufferList)|创建BufferList|
|[Send](#send)|发送给当前flow对象的BufferList|
|[Recv](#recv)|接收给当前flow对象的BufferList|
|[Close](#close)|关闭当前ExternalDataMap对象，等待数据完全处理完成|
|[Shutdown](#shutdown)|强制关闭当前ExternalDataMap对象，无论数据是否处理完成|
|[SetOutputMeta](#setoutputmeta)|设置当前对象输入端口的DataMeta值|
---

## CreateBufferList

创建BufferList

```c++
    std::shared_ptr<BufferList> CreateBufferList()
```

**args:**  

无

**return:**  

modelbox::BufferList  创建存储数据的BufferList

## Send

发送给当前flow对象的BufferList

```c++
    Status Send(const std::string& port_name,
              std::shared_ptr<BufferList> buffer_list)
```

**args:**  

* **port_name** (string) ——  发送数据的目标端口名字
* **buffer_list** (modelbox::BufferList) —— 发送的数据

**return:**  

modelbox::Status 发送数据的状态

## Recv

接收给当前flow对象的BufferList

```c++
    using OutputBufferList = std::unordered_map<std::string, std::shared_ptr<BufferList>>;
    Status Recv(OutputBufferList& map_buffer_list, int32_t timeout = 0)
```

**args:**  

* **map_buffer_list** (OutputBufferList) ——  接收数据的数据结构对象
* **timeout** (int32_t) —— 超时的时间

**return:**  

modelbox::Status 接收给当前flow对象的BufferList的状态

## Close

关闭当前ExternalDataMap对象，等待数据完全处理完成

```c++
    Status Close()
```

**args:**  

无

**return:**  

modelbox::Status 关闭当前ExternalDataMap对象的状态

## Shutdown

强制关闭当前ExternalDataMap对象

```c++
    Status Shutdown()
```

**args:**  

无

**return:**  

modelbox::Status 强制关闭当前ExternalDataMap对象的状态

## SetOutputMeta

设置当前对象输入端口的DataMeta值

```c++
     Status SetOutputMeta(const std::string& port_name,
                       std::shared_ptr<DataMeta> meta)
```

**args:**  

* **port_name** (string) ——  设置meta的目标端口名字
* **meta** (modelbox::DataMeta) —— 设置的数据meta

**return:**  

modelbox::Status 设置当前对象输入端口的DataMeta的状态

**example:**  

```c++
    #include <modelbox/flow.h>

    int main() {
        auto flow = std::make_shared<Flow>();
        auto external_map = flow->CreateExternalDataMap();
        auto buffer_list = external_map->CreateBufferList();
        auto data_meta = std::make_shared<DataMeta>()
        data_meta->SetMeta("test", "test");
        external_map->SetOutputMeta("input1", data_meta);

        // build buffer
        ...

        auto status = external_map->Send("input1", buffer_list);

        OutputBufferList map_buffer_list;
        status = extern_data->Recv(map_buffer_list);
        
        extern_data->Close();
        // or shutdown
        extern_data->ShutDown();
        return 0;
    }

```
