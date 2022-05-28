# modelbox::DriverDesc

|函数|作用|
|-|-|
|[SetName](#setname)|设置插件名字|
|[SetClass](#setclass)| 设置插件类别|
|[SetType](#settype)|设置插件类型|
|[SetDescription](#setdescription)|设置插件描述|
|[SetVersion](#setversion)|设置插件版本|
|[SetFilePath](#setfilepath)|设置文件路径|
|[SetNodelete](#setnodelete)|设置插件为不需要删除|
|[SetGlobal](#setglobal)|设置插件符号为全局可见|
|[SetDeepBind](#setdeepbind)|设置插件符号解析为优先使用当前插件|
---

## SetName

```c++
     void SetName(const std::string &name);
```

**args:**

* **name** (string) —— 插件的名字

**return:**  

无

## SetClass

```c++
     void SetClass(const std::string &classname);
```

**args:**

* **classname** (string) —— 插件的类型，例如：DRIVER-FLOWUNIT, DRIVER-DEVICE等等, 具体可以参考其他流单元的实现

**return:**  

无

## SetType

```c++
     void SetType(const std::string &type);
```

**args:**

* **type** (string) —— 插件的设备类型，例如：cpu, cuda, ascend

**return:**  

无

## SetDescription

```c++
     void SetDescription(const std::string &description);
```

**args:**

* **description** (string) —— 插件的详细描述

**return:**  

无

## SetVersion

```c++
     Status SetVersion(const std::string &version);
```

**args:**

* **version** (string) —— 插件的版本,为x.y.z的形式

**return:**  

modelbox::Status, 设置是否成功, 非必须， 默认为空

## SetFilePath

```c++
     void SetFilePath(const std::string &file_path);
```

**args:**

* **file_path** (string) —— 插件的具体位置

**return:**  

无, 非必须

## SetNodelete

```c++
     void SetNodelete(const bool &no_delete);
```

**args:**

* **no_delete** (bool) —— 是否为RTLD_NODELETE

**return:**  

无, 非必须，默认为false

## SetGlobal

```c++
     void SetGlobal(const bool &global);
```

**args:**

* **global** (bool) —— 是否为RTLD_GLOBAL

**return:**  

无, 非必须，默认为false

## SetDeepBind

```c++
     void SetDeepBind(const bool &deep_bind);
```

**args:**

* **deep_bind** (bool) —— 是否为RTLD_DEEPBIND

**return:**  

无, 非必须，默认为false

**example:**

```c++
    // xxx_flowunit.cc
    MODELBOX_DRIVER_FLOWUNIT(desc) {
        desc.Desc.SetName(FLOWUNIT_NAME);
        desc.Desc.SetClass(modelbox::DRIVER_CLASS_FLOWUNIT);
        desc.Desc.SetType(FLOWUNIT_TYPE);
        desc.Desc.SetDescription(FLOWUNIT_DESC);
        desc.Desc.SetVersion("1.0.0");
    }

    // or flowunit_desc.cc
    void DriverDescription(modelbox::DriverDesc *desc) {
        desc->SetName(FLOWUNIT_NAME);
        desc->SetClass(modelbox::DRIVER_CLASS_FLOWUNIT); // "DRIVER-FLOWUNIT"
        desc->SetType(modelbox::DEVICE_TYPE); // "cpu"
        desc->SetDescription(FLOWUNIT_DESC);
        desc->SetNodelete(true);
        desc->SetGlobal(true);
        return;
    }

```

**result:**

设置了插件的属性值
