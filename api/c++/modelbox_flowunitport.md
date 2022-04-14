# modelbox port属性

|函数|作用|
|-|-|
|[FlowUnitInput](#flowunitinput)|流单元输入端口|
|[FlowUnitOutput](#flowunitoutput)|流单元输出端口|
|[FlowUnitOption](#flowunitoption)|流单元配置项|
---

## modelbox::FlowUnitInput

```c++
    FlowUnitInput(const std::string &name);
    FlowUnitInput(const std::string &name, const std::string &device_type);
    FlowUnitInput(const std::string &name, uint32_t device_mem_flags);
    FlowUnitInput(const std::string &name, const std::string &device_type,
                uint32_t device_mem_flags);
```

**args:**

* **name** (string) —— 输入端口的名字
* **device_type** (string) —— 输入端口的设备类型
* **device_mem_flags** (uint32_t) —— 输入端口设备内存类型

**return:**  

无

## modelbox::FlowUnitOutput

```c++
    FlowUnitOutput(const std::string &name);
    FlowUnitOutput(const std::string &name, uint32_t device_mem_flags);
```

**args:**

* **name** (string) —— 输入端口的名字
* **device_mem_flags** (uint32_t) —— 输入端口设备内存类型

**return:**  

无

## modelbox::FlowUnitOption

```c++
    FlowUnitOption(const std::string &name, const std::string &type)
    FlowUnitOption(const std::string &name, const std::string &type, bool require)
    FlowUnitOption(const std::string &name, const std::string &type, bool require,
                 const std::string &default_value, const std::string &desc)
     FlowUnitOption(const std::string &name, const std::string &type, bool require,
                 const std::string &default_value, const std::string &desc,
                 const std::map<std::string, std::string> &values);
```

**args:**

* **name** (string) —— 配置的名字
* **type** (string) —— 配置的数值类型
* **require** (bool) —— 配置是否必须
* **default_value** (string) —— 配置的默认值
* **desc** (string) —— 配置的描述
* **values** (map) —— 配置可以选择的参数map

**return:**  

无

**example:**

```c++
    std::map<std::string, cv::InterpolationFlags> kCVResizeMethod = {
        {"inter_nearest", cv::INTER_NEAREST},
        {"inter_linear", cv::INTER_LINEAR},
        {"inter_cubic", cv::INTER_CUBIC},
        {"inter_area", cv::INTER_AREA},
        {"inter_lanczos4", cv::INTER_LANCZOS4},
        {"inter_max", cv::INTER_MAX},
        {"warp_fill_outliers", cv::WARP_FILL_OUTLIERS},
        {"warp_inverse_map", cv::WARP_INVERSE_MAP},
    };

    MODELBOX_FLOWUNIT(CVResizeFlowUnit, desc) {
        desc.SetFlowUnitName(FLOWUNIT_NAME);
        desc.SetFlowUnitGroupType("Image");
        desc.AddFlowUnitInput({"in_image"});
        desc.AddFlowUnitOutput({"out_image"});
        desc.SetFlowType(modelbox::NORMAL);
        desc.SetInputContiguous(false);
        desc.SetDescription(FLOWUNIT_DESC);
        desc.AddFlowUnitOption(modelbox::FlowUnitOption("image_width", "int", true,
                                                        "640", "the resize width"));
        desc.AddFlowUnitOption(modelbox::FlowUnitOption("image_height", "int", true,
                                                        "480", "the resize height"));

        std::map<std::string, std::string> method_list;

        for (auto &item : kCVResizeMethod) {
            method_list[item.first] = item.first;
        }

        desc.AddFlowUnitOption(
            modelbox::FlowUnitOption("interpolation", "list", true, "inter_linear",
                                    "the resize interpolation method", method_list));
    }
```
