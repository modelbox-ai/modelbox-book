# modelbox.Device

|函数|作用|
|-|-|
|[get_device_id](#modelboxdevicegetdeviceid)|获取当前设备编号, e.g. 0, 1, 2|
|[get_type](#modelboxdevicegettype)|获取当前设备类型, e.g. cpu, cuda, ascend|
|[get_device_desc](#modelboxdevicegetdevicedesc)|获取当前设备描述|
---

## modelbox.Device.get_device_id

获取当前设备编号。

**args:**  

无

**return:**  

str  设备编号

## modelbox.Device.get_type

获取当前设备类型。

**args:**  

无

**return:**  

str  设备的类型信息

## modelbox.Device.get_device_desc

获取当前设备描述。

**args:**  

无

**return:**  

str  设备的描述信息

**example:**  

```python
    ...
    def process(self, data_ctx):
        device = get_bind_device()
        print(device.get_device_id())
        print(device.get_device_type())
        print(device.get_device_desc())
        ...
        
        return modelbox.Status()
        
```

**result:**  

> "0"  
> "cpu"  
> "this is a cpu device"
