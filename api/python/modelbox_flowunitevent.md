# modelbox.FlowUnitEvent

|函数|作用|
|-|-|
|[set_private_string](#modelboxflowuniteventsetprivatestring)|设置FlowUnitEvent事件中的私有字符串值|
|[get_private_string](#modelboxflowuniteventgetprivatestring)|获取FlowUnitEvent事件中的私有字符串值|
|[set_private_int](#modelboxflowuniteventsetprivateint)|设置FlowUnitEvent事件中的私有整型值|
|[get_private_int](#modelboxflowuniteventgetprivateint)|获取FlowUnitEvent事件中的私有整型值|
---

## modelbox.FlowUnitEvent.set_private_string

设置FlowUnitEvent私有字符串值

**args:**  

* **key** (str)  ——  设置字符串型值得key

* **value** (str) ——  设置字符串型值的value

**return:**  

无

## modelbox.FlowUnitEvent.get_private_string

获取FlowUnitEvent私有字符串值

**args:**  

* **key** (str)  ——  设置字符串型值得key

**return:**  

str  获取当前key值的字符串型value值

## modelbox.FlowUnitEvent.set_private_int

设置FlowUnitEvent私有整型值

**args:**  

* **key** (str)  ——  设置整型值得key

* **value** (int) ——  设置整型值的value

**return:**  

无

## modelbox.FlowUnitEvent.get_private_int

获取FlowUnitEvent私有整型值

**args:**  

* **key** (str)  ——  设置整型值得key

**return:**  

int  获取当前key值的整型value值

**example:**  

```python
    ...
    def process(self, data_ctx):
        event = modelbox.FlowUnitEvent()
        event.set_private_string("test", "test")
        print(event.get_private_string("test"))
        event.set_private_int("int", 33)
        print(event.get_private_int("int"))
        ...
        
        return modelbox.Status()
        
```

**result:**  

> "test"  
> 33
