# modelbox.Flow

|函数|作用|
|-|-|
|[init](#modelboxflowinit)|初始化flow对象|
|[build](#modelboxflowbuild)|构建flow对象，当中主要通过配置文件构建图|
|[run](#modelboxflowrun)|同步运行flow|
|[run_async](#modelboxflowrunasync)|异步运行flow|
|[wait](#modelboxflowwait)|flow对象等待返回|
|[stop](#modelboxflowstop)|停止flow|
|[create_external_data_map](#modelboxflowcreateexternaldatamap)|创建external_data_map|
---

## modelbox.Flow.init

初始化flow对象

### modelbox.Flow.init(conf_file, format)  

**args:**  

* **conf_file** (str) ——  构建流程图的toml文件  
* **format** (modelbox.Flow.Format) ——  流程图的format格式，默认可不填

### modelbox.Flow.init(name, graph, format)

**args:**

* **name** (str) ——  构建图的名称  
* **graph** (str) —— 流程图  
* **format** (modelbox.Flow.Format) ——  流程图的format格式，默认可不填

### modelbox.Flow.init(config)

**args:**

* **config** (modelbox.Configuration) —— 构建图的config

**return:**  

modelbox.Status 初始化flow的状态

## modelbox.Flow.build

构建flow对象，当中主要通过配置文件构建图

**args:**  

无

**return:**  

modelbox.Status 构建flow的状态

## modelbox.Flow.run

同步运行flow

**args:**  

无

**return:**  

modelbox.Status 同步运行flow的状态

## modelbox.Flow.run_async

异步运行flow

**args:**  

无

**return:**  

modelbox.Status 异步运行flow的状态

## modelbox.Flow.wait

flow对象等待返回

**args:**  

无

**return:**  

modelbox.Status 等待flow的状态

## modelbox.Flow.stop

停止运行flow

**args:**  

无

**return:**  

modelbox.Status 停止运行flow的状态

**example:**  

```python
   ...
   conf_file = "test.toml"
   ret = flow.init(conf_file)
   ret = flow.build()
   async = True
   if async == True:
    ret = flow.run_async()
   else:
    ret = flow.run()
   retval = modelbox.Status()
   ret = flow.wait(0, retval)
   ret = flow.stop()
        
```

**result:**  

flow的构建流程

## modelbox.Flow.create_external_data_map

创建external_data_map

**args:**  

无

**return:**  

modelbox.ExternalDataMap, 创建好的external_data_map

**example:**  

```python
   flow = modelbox.Flow()
   extern_data_map = flow.create_external_data_map()
```

**result:**  

通过flow构建external_data_map
