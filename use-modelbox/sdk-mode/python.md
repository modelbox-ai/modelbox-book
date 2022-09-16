# Python开发方式

开发前请先准备好ModelBox开发环境，详见[环境准备](../../environment/compile.md)章节。

## Python SDK API接口说明

| 类    | 方法  | 参数 | 功能 |
| ----- | ---- |----- | -----|
| modelbox.FlowConfig | set_queue_size | queue_size: 流程图中节点之间的数据队列大小 | 设置流程图中节点之间的数据队列大小 |
|  | set_batch_size | batch_size: 流程图中节点处理的批数据大小 | 设置流程图中节点处理的批数据大小 |
|  | set_drivers_dir | drivers_dir_list: 流程图中节点的额外扫描目录 | 设置流程图中节点的额外扫描目录 |
|  | set_skip_default_drivers | is_skip: 是否跳过ModelBox默认的扫描路径 | 设置是否跳过ModelBox默认的扫描路径 |
| modelbox.FlowGraphDesc | init | 无 | 初始化图描述 |
|  | init | config: 图描述的配置 | 初始化图描述 |
|  | add_input | input_name: 图输入端口名称 | 为图添加输入端口 |
|  | add_output | output_name: 图输出端口名称<br>source_node_port: 作为图输出端口的节点输出端口 | 为图添加输出端口 |
|  | add_output | output_name: 图输出端口名称<br>source_node: 作为图输出端口的单端口节点 | 为图添加输出端口 |
|  | add_node | flowunit_name: 使用的功能单元名称<br>device: 节点依赖的设备<br>config: 节点的配置列表<br>source_node_ports: 其他节点输出端口与本节点输入端口的连接关系 | 添加一个功能单元作为流程图的节点 |
|  | add_node | flowunit_name: 使用的功能单元名称<br>device: 节点依赖的设备<br>config: 节点的配置列表<br>source_node: 与当前节点连接的单输出节点 | 添加一个功能单元作为流程图的节点 |
|  | add_node | flowunit_name: 使用的功能单元名称<br>device: 节点依赖的设备<br>source_node_ports: 其他节点输出端口与本节点输入端口的连接关系 | 添加一个功能单元作为流程图的节点 |
|  | add_node | flowunit_name: 使用的功能单元名称<br>device: 节点依赖的设备<br>source_node: 与当前节点连接的单输出节点 | 添加一个功能单元作为流程图的节点 |
|  | add_node | flowunit_name: 使用的功能单元名称<br>device: 节点依赖的设备<br>config: 节点的配置列表 | 添加一个功能单元作为流程图的节点 |
| modelbox.Flow | init | configfile: 指定config文件的路径<br>format： 指定图文件的格式，可选项为 FORMAT_AUTO,FORMAT_TOML，FORMAT_JSON | 初始化ModelBox服务，主要包含功能如下：<br>1. 读取driver参数，获取driver的扫描路径<br>2. 扫描指定路径下的driver文件，并创建driver实例<br>3. 加载流程图并转换为ModelBox可识别的模型<br>4. 初始化设备信息，性能跟踪和数据统计单元 |
|  | init | name: 指定的图的名称<br>graph: 存储图的字符串<br>format：指定图的格式 | 与上面init的区别是，上面通过读取文件的方式，而此函数通过读取字符串的方式，其他功能相同 |
|  | init | config: Configuration指针，存储图信息  | 功能同上 |
|  | init | flow_graph_desc: 图描述 | 功能同上 |
|  | start_run | 无 | 启动流程图 |
|  | stop | 无 | 停止流程图 |
|  | create_stream_io | 无 | 在流程图中创建一个数据流的输入输出句柄 |
| modelbox.FlowStreamIO | create_buffer | 无 | 创建空buffer用于存储数据 |
|  | create_buffer | data: Python Buffer Protocol类型的数据 |　根据Python Buffer Protocol类型的data创建一个buffer, 如numpy的ndarray |
|  | create_buffer | data: string类型的数据 | 根据string类型的data创建一个buffer |
|  | send | input_name: 图的输入端口名<br>buffer: ModelBox的Buffer数据 | 发送数据到图的输入端口 |
|  | send | input_name: 图的输入端口名<br>data: Python Buffer Protocol类型的数据 | 发送数据到图的输入端口 |
|  | send | input_name: 图的输入端口名<br>data: string类型的数据 | 发送数据到图的输入端口 |
|  | recv | output_name: 图的输出端口名<br>buffer: 输出数据<br>timeout: 等待超时 | 接受图的输出数据 |
|  | recv | output_name: 图的输出端口名<br>timeout: 等待超时 | 接受图的输出数据 |
|  | recv | output_name: 图的输出端口名 | 接受图的输出数据 |
|  | close_input | 无 | 结束输入的数据流，将会告知ModelBox输入数据是否已经完毕 |
| modelbox.Model | __init__ | path: 模型路径<br>name: 模型配置中描述的名称<br>in_names: 输入端口名<br>out_names: 输出端口名<br>max_batch_size: 一次推理的最大batch<br>device: 设备类型，"cpu", "gpu", "ascend"可选<br>device_id: 设备ID| 构建ModelBox单模型推理对象 |
|  | start | 无 | 启动ModelBox单模型推理对象 |
|  | stop | 无 | 停止ModelBox单模型推理对象 |
|  | infer | data_list: 每个端口的输入组成的列表，与定义的端口顺序一致 | 单batch放入数据，底层执行推理时会自动合并batch |
|  | infer_batch | data_list: 每个端口的多输入组成的列表，与定义的端口顺序一致 | 便于将一批数据送入，底层会按照模型的batch配置决定执行时的真实batch |

Python开发AI应用的大致流程如下：

1. 安装Python SDK包。
1. 开发流程图之外的应用部分。
1. 开发流程图的流程，以及流程中使用的功能单元。
1. 使用Flow的接口创建流程图对象。
1. 使用流程图对象写入数据。
1. 在使用数据的地方读取数据。
1. 不再使用流程图时，可调用stop释放图资源。

## 使用场景

### 通过流程图配置初始化流程图对象

SDK模式的流程图的开发和标准模式基本一样，具体开发介绍见[流程图开发](../standard-mode/flow/flow.md)章节。SDK模型区别可以通过设置input和output端口作为外部数据的输入和输出。具体配置如下：

```toml
[driver]
dir=""
[graph]
graphconf = '''digraph demo {
  input1[type=input] # 定义input类型端口，端口名为input1，用于外部输入数据
  resize[type=flowunit, flowunit=resize, device=cuda]
  model_detect[type=flowunit, flowunit=model_detect, device=cuda]
  yolobox_post[type=flowunit, flowunit=yolobox_post, device=cpu]
  output1[type=output] # 定义output类型端口，端口名为output1，用于外部获取输出结果
   
  input1 -> resize:in_image
  resize:out_image -> model_detect:in
  model_detect:output -> yolobox_post:in
  yolobox_post:out -> output1
}'''
format = "graphviz"
```

如上图，input1和output1端口作为图的输入和输出，如果需要设置多个外部输入输出端口，可按照图配置规则配置多个。

配置好流程图之后，使用API初始化流程图对象

```python
import modelbox

flow = modelbox.Flow()
flow.init(flow_file_path)
```

### 通过流程图描述初始化流程图对象

通过API直接描述流程图

```python
import modelbox

# set graph config
graph_cfg = modelbox.FlowGraphConfig();
graph_cfg.set_queue_size(32)
graph_cfg.set_batch_size(16)
graph_cfg.set_skip_default_drivers(False)
graph_cfg.set_drivers_dir(["/xxx/xxx/"])

# construct graph
graph_desc = modelbox.FlowGraphDesc()
graph_desc.init(graph_cfg)
# graph_desc.init() # init by default config

input = graph_desc.add_input("input1")
resize = graph_desc.add_node("resize", "cuda", {"image_width=128", "image_height=128"}, input)
model_detect = graph_desc.add_node("model_detect", "cuda", resize)
yolobox_post = graph_desc.add_node("yolobox_post", "cpu", model_detect)
graph_desc.add_output("output1", yolobox_post)

# start flow
flow = modelbox.Flow()
flow.init(graph_desc)
flow.start_run()
```

### 流程图数据输入输出

通过上述两个方式构建好flow后，就可以使用flow进行数据处理了。

```python
stream_io = flow.create_stream_io()

# write img
img = cv.imread("path.jpg")
## method 1
buffer = stream_io.create_buffer(img)
buffer.set("meta", "meta")
stream_io.send("input1", buffer)
## method 2
stream_io.send(img)

# write numpy
tensor = numpy.ones((10, 10, 3))
## method 1
buffer = stream_io.create_buffer(tensor)
buffer.set("meta", "meta")
stream_io.send("input1", buffer)
## method 2
stream_io.send(tensor)

# write str
url = "rtsp://x.x.x.x/x.sdp"
## method 1
buffer = stream_io.create_buffer(url)
buffer.set("meta", "meta")
stream_io.send("input1", buffer)
## method 2
stream_io.send(url)

# write list
floats = numpy.array([1.0, 2.0, 3.0, 4.0])
## method 1
buffer = stream_io.create_buffer(floats)
buffer.set("meta", "meta")
stream_io.send("input1", buffer)
## method 2
stream_io.send("input1", floats)

# recv buffer
result = stream_io.recv("output1")

# buffer to numpy
data = numpy.array(result)

# buffer to str
data2 = str(result)
```

### 使用快捷的单模型推理接口

对于想快速使用ModelBox对模型进行推理场景，可以使用如下的方式

```python
import modelbox

# load model
model = modelbox.Model(path, name, in_names, out_names, max_batch_size, device, device_id)
model.start()

# single batch inference
data1_np = numpy.ones((3, 3, 3))
data2_np = numpy.ones((10, 10, 3))
input_list = [data1_np, data2_np]
output_list = model.infer(input_list)
output_buffer = output_list[output_index]
output_np = numpy.array(output_buffer)

# multi batch inference
data1_batch_np = [numpy.ones((3, 3, 3)), numpy.ones((3, 3, 3))]
data2_batch_np = [numpy.ones((10, 10, 3)), numpy.ones((10, 10, 3))]
input_batch_list = [data1_batch_np, data2_batch_np]
output_batch_list = model.infer_batch(input_batch_list)
output_buffer = output_batch_list[output_index][batch_index]
output_np = numpy.array(output_buffer)
```

### 日志接口

应用程序可以设置modelbox的日志级别，并且可以使用modelbox的日志系统

```python
# set log level
modelbox.set_log_level(modelbox.Log.Level.DEBUG)
modelbox.set_log_level(modelbox.Log.Level.INFO)
modelbox.set_log_level(modelbox.Log.Level.NOTICE)
modelbox.set_log_level(modelbox.Log.Level.WARN)
modelbox.set_log_level(modelbox.Log.Level.ERROR)
modelbox.set_log_level(modelbox.Log.Level.FATAL)
modelbox.set_log_level(modelbox.Log.Level.OFF)

modelbox.debug("")
modelbox.info("")
modelbox.notice("")
modelbox.warn("")
modelbox.error("")
modelbox.fatal("")
```
