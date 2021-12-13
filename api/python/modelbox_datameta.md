# modelbox.DataMeta

|函数|作用|
|-|-|
|[set_private_string](#modelboxdatametasetprivatestring)|设置datameta中的私有字符串值|
|[get_private_string](#modelboxdatametagetprivatestring)|获取datameta中的私有字符串值|
|[set_private_int](#modelboxdatametasetprivateint)|设置datameta中的私有整型值|
|[get_private_int](#modelboxdatametagetprivateint)|获取datameta中的私有整型值|
---

## modelbox.DataMeta.set_private_string

设置DataMeta私有字符串值

**args:**  

* **key** (str)  ——  设置字符串型值得key

* **value** (str) ——  设置字符串型值的value

**return:**  

无

## modelbox.DataMeta.get_private_string

获取DataMeta私有字符串值

**args:**  

* **key** (str)  ——  需要获取的字符串型的key

**return:**  

str  获取当前key值的字符串型value值

## modelbox.DataMeta.set_private_int

设置DataMeta私有整型值

**args:**  

* **key** (str)  ——  设置整型值得key

* **value** (int)  设置整型值的value

**return:**  

无

## modelbox.DataMeta.get_private_int

获取DataMeta私有整型值

**args:**  

* **key** (str)  ——  需要获取的整型的key

**return:**  

int  获取当前key值的整型value值

**example:**  

```python
    ...
    def Process(self, data_ctx):
        data_meta = modelbox.DataMeta()
        data_meta.set_private_string("test", "test")
        print(data_meta.get_private_string("test"))
        data_meta.set_private_int("int", 33)
        print(data_meta.get_private_int("int"))
        ...
        
        return modelbox.Status()
        
```

**result:**

> "test"  
> 33
