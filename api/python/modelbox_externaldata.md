# modelbox.ExternalData

|函数|作用|
|-|-|
|[create_buffer_list](#modelboxexternaldatacreatebufferlist)|创建BufferList|
|[send](#modelboxexternaldatasend)|发送要给本流单元的process单元的BufferList|
|[get_session_context](#modelboxexternaldatagetsessioncontext)|获取session_context对象|
|[get_session_config](#modelboxexternaldatagetsessionconfig)|获取session_config对象|
|[close](#modelboxexternaldataclose)|关闭当前external_data的链接|
---

## modelbox.ExternalData.create_buffer_list

创建BufferList

**args:**  

无

**return:**  

modelbox.BufferList

## modelbox.ExternalData.send

发送BufferList给下一个流单元

**args:**  

* **bufferlist** (modelbox.BufferList) ——  需要发送的BufferList

**return:**  

modelbox.Status  发送的返回状态

## modelbox.ExternalData.close

关闭external对象

**args:**  

无

**return:**  

modelbox.Status  关闭的返回状态

**example:**  

```python
    ...
    def Open(self, config):
        extern_data = create_external_data()
        buffer_list = extern_data.create_buffer_list()

        buffer = np.ones((5,5))
        
        buffer_list.push_back(buffer)
        extern_data.send(buffer_list)
        extern_data.close()
        ...

        return modelbox.Status()
        
```

**result:**  

本流单元的process既可以接受到当前BufferList 

## modelbox.ExternalData.get_session_context

获取session_context对象

**args:**  

无

**return:**  

modelbox.SessionContext

## modelbox.ExternalData.get_session_config

获取session_config对象

**args:**  

无

**return:**  

modelbox.SessionConfig

**example:**  

```python
    ...
    def Open(self, config):
        extern_data = create_external_data()
        session_config = extern_data.get_session_config()
        session_context = extern_data.get_session_context()
        ...

        return modelbox.Status()
        
```

**result:**  

获取session_config和session_context
