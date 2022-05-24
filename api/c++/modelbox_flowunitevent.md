# modelbox::FlowUnitEvent

|函数|作用|
|-|-|
|[构造方法](#构造方法)|构造flowunitevent|
|[SetPrivate](#setprivate)|设置flowunitevent中的私有值|
|[GetPrivate](#getprivate)|获取flowunitevent中的私有值|
---

## 构造方法

```c++
    FlowUnitEvent();
```

**example:**

```c++
    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto event = std::make_shared<FlowUnitEvent>();
        event->SetPrivate("index", index_counter);
        auto index_counter = event->GetPrivate("index");
        MBLOG_INFO << *index_counter;
    }
```

## SetPrivate

设置当前flowunit中保存在flowunitevent中的对象

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

获取当前flowunit中保存在flowunitevent中的对象

```c++
    std::shared_ptr<void> GetPrivate(const std::string &key);
```

**args:**  

* **key** (str)  ——  需要获取对象的key值

**return:**  

`shared_ptr<void>` key值对应的value的智能指正

**example:**  

```c++

    Status Process(std::shared_ptr<DataContext> data_ctx) {
        auto index_counter = std::make_shared<int64_t>(0);
        auto event = std::make_shared<FlowUnitEvent>();
        event->SetPrivate("index", index_counter);
        auto index_counter = event->GetPrivate("index");
        MBLOG_INFO << *index_counter;
    }
```

**result:**  

> 0
