# modelbox.FlowUnitError

|函数|作用|
|-|-|
|[get_description](#modelboxflowuniterrorgetdescription)|获取error的描述信息|
|[构造方法](#构造方法)|构造modelbox.FlowUnitError|
---

## 构造方法

构造modelbox.FlowUnitError

**args:**  

* **error** (str) —— 具体的error描述

**return:**  

modelbox.FlowUnitError

## modelbox.FlowUnitError.get_description

获取error的描述信息

**args:**  

无

**return:**  

str, 当前error的描述信息

**example:**  

```python
   ...
   error = modelbox.FlowUnitError("this is error")
   err_desc = error.get_description()
   print(error)
```

**result:**  

> "this is error"
