# modelbox::SessionContext

整个stream过程的全局会话上下文

|函数|作用|
|-|-|
|[SetPrivate](#setprivate)|设置session_context中的私有值|
|[GetPrivate](#getprivate)|获取session_context中的私有值|
|[SetSessionId](#setsessionid)|设置session_context中的session id|
|[GetSessionId](#getsessionid)|获取session_context中的session id|
---

## SetPrivate

设置SessionContext私有值

```c++
    void SetPrivate(const std::string &key,
                  std::shared_ptr<void> private_content);
```

**args:**  

* **key** (string)  —— 设置对象的key值
* **private_content** (`shared_ptr<void>`) —— 设置对象的val的智能指针

**return:**  

无

## GetPrivate

获取SessionContext私有值

```c++
    std::shared_ptr<void> GetPrivate(const std::string &key);
```

**args:**  

* **key** (str)  ——  需要获取对象的key值

**return:**  

`shared_ptr<void>` key值对应的value的智能指针

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto index_counter = std::make_shared<int64_t>(0);
        auto session_context = data_ctx->GetSessionContext();
        session_context->SetPrivate("index", index_counter);
        auto index_counter = session_context->GetPrivate("index");
        MBLOG_INFO << *index_counter;
    }     
```

**result:**  

> 0  

## SetSessionId

设置session_id

**args:**  

* **session_id** (string)  ——  设置会话的id

**return:**  

无

## GetSessionId

获取session_id

**args:**  

无

**return:**  

string  获取当前session的id

**example:**  

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto session_context = data_ctx->GetSessionContext();
        session_context->SetSessionId("12345");
        auto res = session_context->GetSessionId("index");
        MBLOG_INFO << *res;
    }
        
```

**result:**  

> 12345
