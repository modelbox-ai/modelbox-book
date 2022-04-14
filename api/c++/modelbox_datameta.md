# modelbox::DataMeta

|函数|作用|
|-|-|
|[SetMeta](#setmeta)|设置DataMeta对象值|
|[GetMeta](#GetMeta)|获取DataMeta特定key的数据|
---

## SetMeta

设置DataMeta对象值

**args:**  

* **key** (string)  ——  设置对象的key值

* **meta** (`shared_ptr<void>`) ——  设置对象的value的智能指针

**return:**  

无

## GetMeta

获取DataMeta特定key的数据

**args:**  

* **key** (str)  ——  需要获取对象的key值

**return:**  

`shared_ptr<void>`  获取当前key值value值

**example:**  

```c++
    ...
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto data_meta = std::make_shared<DataMeta>()
        data_meta->SetMeta("test", "test");
        MBLOG_INFO << data_meta->GetMeta("test");
        ...
        
        return STATUS_OK;
    }
        
```

**result:**

> "test"
