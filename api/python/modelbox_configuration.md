# modelbox.Configuration

|函数|作用|
|-|-|
|[get](#modelboxconfigurationget)|从configuration对象当中获取值|
|[set](#modelboxconfigurationset)|在configuration对象中设置值|
---

## modelbox.Configuration.set

**args:**  

key: str  meta的key值

obj: int, str, double, bool, list[str], list[int], list[double], list[bool]  
meta的value值

**return:**  

无

## modelbox.Configuration.get

**api:**  
| 函数名 | 功能 |
|-|-|
| get_string | 获取字符串值 |
| get_int | 获取整型值|
| get_float | 获取浮点型值 |
| get_bool | 获取布尔值|
| get_string_list | 获取字符串列表值 |
| get_int_list | 获取整型列表值 |
| get_float_list | 获取浮点型列表值 |
| get_bool_list | 获取布尔列表值 |

**args:**  

* **key** (str) ——  需要获取的meta的key值

**return:**  

python object 获取key对应的value值

type: int, double, str, bool, list[int], list[str], list[double], list[bool]

**example:**  

```python
    ...
    def Open(self, data_ctx, config):
        config.set("int", 3)
        config.set("bool", True)
        config.set("string", "test")
        config.set("float", 3.1)
        config.set("ints", [3,4])
        config.set("bools", [True, False])
        config.set("strings", ["test1", "test2"])
        config.set("floats", [3.1, 3.2])
        print(config.get_int("int"))
        print(config.get_int_list("ints"))
        print(config.get_bool("bool"))
        print(config.get_bool_list("bools"))
        print(config.get_string("string"))
        print(config.get_string_list("strings"))
        print(config.get_float("float"))
        print(config.get_float_list("floats"))
        ...
        
        return modelbox.Status()
        
```

**result:**

> 3  
> [3,4]  
> True  
> [True, False]  
> "test"  
> ["test1", "test2"]  
> 3.1  
> [3.1, 3.2]
