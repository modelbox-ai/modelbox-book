# modelbox.SessionContext

|函数|作用|
|-|-|
|[set_private_string](#modelboxsessioncontextsetprivatestring)|设置SessionContext中的私有字符串值|
|[get_private_string](#modelboxsessioncontextgetprivatestring)|获取SessionContext中的私有字符串值|
|[set_private_int](#modelboxsessioncontextsetprivateint)|设置SessionContext中的私有整型值|
|[get_private_int](#modelboxsessioncontextgetprivateint)|获取SessionContext中的私有整型值|
|[get_session_config](#modelboxsessioncontextgetsessionconfig)|获取SessionContext中的配置对象|
|[get_session_id](#modelboxsessioncontextgetsessionid)|获取SessionContext的ID|
---

## modelbox.SessionContext.set_private_string

设置SessionContext私有字符串值。

**args:**  

* **key** (str)  ——  设置字符串型值得key

* **value** (str) ——  设置字符串型值的value

**return:**  

无

## modelbox.SessionContext.get_private_string

获取SessionContext私有字符串值。

**args:**  

* **key** (str)  ——  设置字符串型值得key

**return:**  

str  获取当前key值的字符串型value值

## modelbox.SessionContext.set_private_int

设置SessionContext私有整型值。

**args:**  

* **key** (str)  ——  设置整型值得key

* **value** (int) ——  设置整型值的value

**return:**  

无

## modelbox.SessionContext.get_private_int

获取SessionContext私有整型值。

**args:**  

* **key** (str)  ——  设置整型值得key

**return:**  

int  获取当前key值的整型value值

**example:**  

```python
    ...
    def process(self, data_ctx):
        session_ctx = data_ctx.get_session_context()
        session_ctx.set_private_string("test", "test")
        print(session_ctx.get_private_string("test"))
        session_ctx.set_private_int("int", 33)
        print(session_ctx.get_private_int("int"))
        ...
        
        return modelbox.Status()
        
```

**result:**  

> "test"  
> 33

## modelbox.SessionContext.get_session_config

获取Session级别配置对象。

**args:**  

无

**return:**  

modelbox.Configuration

## modelbox.SessionContext.get_session_id

获取Session ID。

**args:**  

无

**return:**  

str  获取当前session的id

**example:**  

```python
    ...
    def process(self, data_ctx):
        session_ctx = data_ctx.get_session_context()
        id = session_ctx.get_session_id()
        config = session_ctx.get_session_config()
        ...
        
        return modelbox.Status()
        
```

