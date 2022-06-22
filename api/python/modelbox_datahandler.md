# modelbox.DataHandler

|函数|作用|
|-|-|
|PushData()|将数据喂给DataHandler绑定节点的端口|
|SetMeta|保存meta信息，在发送数据的时候附带上|
|GetMeta|获取meta信息|
|GetDataHandler|获取节点某个端口绑定的Datahandler对象|
|SetDataHandler|将多个端口对象合并为一个节点对象|
|GetBufferList|获取某个端口上的数据|
|Next|获取某个端口上的数据信息，存储在DataHandler对象中|
|SetNodeName|设置DataHandler对象绑定的节点名称|
|GetNodeName|获取DataHandler对象绑定的节点名称|
|Close|关闭DataHandler，关闭之后无法再发送数据|

## modelbox.DataHandler.PushData
发送数据到节点的某个端口

**args:**
* data: DataHandler
* port_name: str

**return:**

status: 操作是否成功

## modelbox.DataHandler.PushData
发送数据到节点的某个端口

**args:**
* data: modelbox.Buffer
* port_name: str

**return:**

status: 操作是否成功

## modelbox.DataHandler.PushData
发送数据到节点的某个端口

**args:**
* data: modelbox.BufferList
* port_name: str

**return:**

status: 操作是否成功

## modelbox.DataHandler.SetMeta
设置meta信息
**args:**
* key:str
* data:str

**return:**

status: 操作是否成功

## modelbox.DataHandler.GetMeta
获取meta信息

**args:**
* key: str

**return:**

value: str

## modelbox.DataHandler.GetDataHandler
从节点DataHandler中获取某个端口的DataHandler对象

**args:**
* port_name: 端口名称

**return:**

DataHandler: 绑定端口的DataHandler对象 

## modelbox.DataHandler.SetDataHandler
通过各个端口的DataHandler组合一个节点的连接关系对应的DataHandler

**args:**
* datahandler_map: map对象，结构为{port_name, datahandler}

**return:**

DataHandler: 返回一个包含端口连接关系的DataHanddler


## modelbox.DataHandler.GetBufferList
获取端口中的数据
**args:**
* port_name: str

**return**

BufferList: 包含数据的BufferList对象

## modelbox.DataHandler.Next
读取处理之后的数据，适用于节点为流功能单元的情况,一般在调用for循环时调用
**args:**
* 无

**return:**

DataHandler对象，包含各个端口输出的数据

## modelbox.DataHandler.SetNodeName
设置节点名称
**args:**
* node_name:str

**return:**

无
## modelbox.DataHandler.GetNodeName
获取节点名称
**args:**
* 无

**return:**

str: 节点名称


## example:
```python
input = modelboxengine.CreateInput()
input.SetMeta("video_url","/xx/xx/xx.mp4")
video_demuxer = modelboxengine.execute("video_demuxer",{}, input)
for packet in video_demuxer:
    packet_data = packet.GetBufferList("packet")

```