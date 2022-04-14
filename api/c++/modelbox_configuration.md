# modelbox::Configuration

|函数|作用|
|-|-|
|[Get](#get)|从configuration对象当中获取值|
|[Size](#size)|configuration对象中存储键值对的数量|
|[GetKeys](#getKeys)|configuration对象中获取所有的key值|
|[Contain](#contain)|configuration对象中是否包含某个key值|
---

## Get

```c++
    std::string GetString(const std::string &key,
                        const std::string &default_prop = "") const;

    bool GetBool(const std::string &key, bool default_prop = false) const;

    int8_t GetInt8(const std::string &key, int8_t default_prop = 0) const;

    uint8_t GetUint8(const std::string &key, uint8_t default_prop = 0) const;

    int16_t GetInt16(const std::string &key, int16_t default_prop = 0) const;

    uint16_t GetUint16(const std::string &key, uint16_t default_prop = 0) const;

    int32_t GetInt32(const std::string &key, int32_t default_prop = 0) const;

    uint32_t GetUint32(const std::string &key, uint32_t default_prop = 0) const;

    int64_t GetInt64(const std::string &key, int64_t default_prop = 0) const;

    uint64_t GetUint64(const std::string &key, uint64_t default_prop = 0) const;

    float GetFloat(const std::string &key, float default_prop = 0.0f) const;

    double GetDouble(const std::string &key, double default_prop = 0.0) const;

    std::vector<std::string> GetStrings(
        const std::string &key,
        const std::vector<std::string> &default_prop = {}) const;

    std::vector<bool> GetBools(const std::string &key,
                                const std::vector<bool> &default_prop = {}) const;

    std::vector<int8_t> GetInt8s(
        const std::string &key,
        const std::vector<int8_t> &default_prop = {}) const;

    std::vector<uint8_t> GetUint8s(
        const std::string &key,
        const std::vector<uint8_t> &default_prop = {}) const;

    std::vector<int16_t> GetInt16s(
        const std::string &key,
        const std::vector<int16_t> &default_prop = {}) const;

    std::vector<uint16_t> GetUint16s(
        const std::string &key,
        const std::vector<uint16_t> &default_prop = {}) const;

    std::vector<int32_t> GetInt32s(
        const std::string &key,
        const std::vector<int32_t> &default_prop = {}) const;

    std::vector<uint32_t> GetUint32s(
        const std::string &key,
        const std::vector<uint32_t> &default_prop = {}) const;

    std::vector<int64_t> GetInt64s(
        const std::string &key,
        const std::vector<int64_t> &default_prop = {}) const;

    std::vector<uint64_t> GetUint64s(
        const std::string &key,
        const std::vector<uint64_t> &default_prop = {}) const;

    std::vector<float> GetFloats(
        const std::string &key,
        const std::vector<float> &default_prop = {}) const;

    std::vector<double> GetDoubles(
        const std::string &key,
        const std::vector<double> &default_prop = {}) const;
```

**args:**  

* **key** (string) ——  需要获取的Meta的key值
* **default_prop** (特定类型) —— 获取key值失败时的默认值

**return:**  

特定类型的值

**example:**  

```c++
    ...
    Status Open(const std::shared_ptr<Configuration> config):
        auto str = config->GetString("string", "default");
        auto strings = config->GetStrings("strings", {"test", "test"});
        auto int32 = config->GetInt32("int32", 1);
        auto int32s = config->GetInt32s("int32s", {1,2,3});
        ...
        MBLOG_INFO << str;
        for (auto &item: strings) {
            MBLOG_INFO << item
        }
        MBLOG_INFO << int32;
        for (auto &item: int32s) {
            MBLOG_INFO << item
        }
        
        return STATUS_OK;
        
```

**result:**

> default
> test
> test  
> 1
> 1  
> 2
> 3  

## Size

```c++
    size_t Size() const;
```

**args:**  

无

**return:**  

size_t, configuration item数量

## GetKeys

```c++
    set<string> GetKeys() const;
```

**args:**  

无

**return:**  

`set<string>`, configuration 所有的key值

## Contain

```c++
    bool Contain(const std::string &key) const;
```

**args:**  

* **key** (string) 需要判断的key值

**return:**  

bool, 该key值是否存在
