# modelbox.Device

|函数|作用|
|-|-|
|[get_device_id](#modelboxdevicegetdeviceid)|获取当前device id, e.g. 0, 1, 2|
|[get_type](#modelboxdevicegettype)|获取当前device 类型, e.g. cpu, cuda|
|[get_device_desc](#modelboxdevicegetdevicedesc)|获取当前device 描述|
---

## modelbox.Device.get_device_id

获取当前device id

**args:**  

无

**return:**  

str  设备的id

## modelbox.Device.get_type

获取当前device type

**args:**  

无

**return:**  

str  设备的类型信息

## modelbox.Device.get_device_desc

获取当前device desc

**args:**  

无

**return:**  

str  设备的描述信息

**example:**  

```python
    ...
    def Process(self, data_ctx):
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
