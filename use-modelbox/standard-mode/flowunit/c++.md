# C++功能单元开发

本章节主要介绍C++功能单元的开发流程。在开发之前，可以从[功能单元概念](../../../basic-conception/flowunit.md#功能单元)章节了解功能单元的执行过程。

## 功能单元创建

ModelBox提供了多种方式进行C++功能单元的创建:

* **通过UI创建**
  
  可参考可视化编排服务的[任务编排页面](../../../plugins/editor.md#功能单元)章节操作步骤。

* **通过命令行创建**

  ModelBox提供了模板创建工具，可以通过**ModelBox Tool**工具产生C++功能单元的模板，具体命令为

  ```shell
  modelbox-tool template -flowunit -project-path [project_path] -name [flowunit_name] -lang c++ -input name=in1,device=cuda -output name=out1
  ```

  该命令将会在`$project_path/src/flowunit`目录下创建名为`flowunit_name`的C++功能单元。

创建完成的C++功能单元目录结构如下：

```shell
[flowunit-name]
     |---CMakeList.txt           # 编译文件，C++功能单元采用CMake进行编译 
     |---[flowunit-name].cc      # 接口实现文件
     |---[flowunit-name].h       # 头文件
     |---[flowunit-name].toml    # 配置文件，用于WebUI显示
```

## 功能单元属性配置

在开发功能单元时，应该先明确开发功能单元处理数据的类型、业务的场景等，根据需求来配置功能单元类型和属性。具体功能单元类型，请查看功能单元基础概念[功能单元类型](../../../basic-conception/flowunit.md#功能单元类型)章节。在确认功能单元类型后，需要对功能单元进行参数的配置。

属性配置包含两部分：Driver插件属性和FlowUnit功能单元属性。Driver和功能单元的关系如下：Driver是ModelBox中各类插件的集合，功能单元属于Driver中的一种类型。在C++语言中，一个Driver对应一个so，一个Driver可以支持注册多个功能单元，即将多个功能单元编译进一个so文件。而再Python中，Driver和功能单元一一对应。如无特殊需求，通常使用一个Driver对应一个功能单元。

典型的属性配置代码如下：

```c++
#include "modelbox/flowunit_api_helper.h"

// 设置FlowUnit功能单元属性
// `ExampleFlowUnit`为对应的插件功能单元派生对象，从FlowUnit派生出来的类
// `MODELBOX_FLOWUNIT`: 一个Driver内部可以注册多个功能单元，`MODELBOX_FLOWUNIT`可以设置多个不同的FlowUnit。
MODELBOX_FLOWUNIT(ExampleFlowUnit, desc) {
  desc.SetFlowUnitName(FLOWUNIT_NAME);          // 功能单元名称
  desc.SetFlowUnitGroupType("Undefined");       // 功能单元组类型
  desc.SetFlowType(modelbox::STREAM);           // 功能单元工作模式
  desc.AddFlowUnitInput({"in", FLOWUNIT_TYPE}); // 功能单元输入端口，名称叫 "in", 同时输入数据如果不在FLOWUNIT_TYPE设备上，则框架会自动将其搬移至该设备上
  desc.AddFlowUnitOutput({"out"});              // 功能单元输出端口，名称叫 "out"
  desc.SetDescription(FLOWUNIT_DESC);           // 功能单元描述
}

// 设置Driver插件相关属性
MODELBOX_DRIVER_FLOWUNIT(desc) {
  desc.Desc.SetName(FLOWUNIT_NAME);             // Driver名称
  desc.Desc.SetClass(modelbox::DRIVER_CLASS_FLOWUNIT);   // Driver功能类型，功能单元取值固定
  desc.Desc.SetType(modelbox::DEVICE_TYPE);     // Driver和功能单元设备类型，取值：cpu、cuda、ascend
  desc.Desc.SetVersion(FLOWUNIT_VERSION);       // Driver版本号
  desc.Desc.SetDescription(FLOWUNIT_DESC);      // Driver描述
  desc.Init([]() {                   
    // 如果有需要Driver相关的初始化功能，可在此实现，插件启用时调用.
    return modelbox::STATUS_OK;
  });
  desc.Exit([]() {
    // 如果有需要Driver相关的去初始化功能，可在此实现，插件关闭时调用.
    return modelbox::STATUS_OK;
  });
  return;
}

```

通常情况下，CPU类型业务功能单元只需确认输入输出端口名即可。如果需要设置其他属性，可参考如下功能单元参数说明：

| 配置项                     | 配置接口          | 必填 | 参数类型    | 功能描述                                                                 |
| -------------------------- | -------------------- | ---- | -------------- | ------------------------------------------------------------------------ |
| 功能单元名称               | SetName      |  是   | String         | 功能单元名称                                                             |
| 功能单元描述               | SetDescription       |  否   | String         | 功能单元描述                                                             |
| 功能单元分组类别             | SetFlowUnitGroupType |  否   | GroupType      | 功能单元分组类别，用于UI分组显示                                                              |
| 功能单元数据处理类型           | SetFlowType          |  是   | FlowType       | 功能单元数据处理类型 ，取值为：`NORMAL` 和 `STREAM`，差异详见[功能单元类型](../../../basic-conception/flowunit.md#功能单元类型)章节。 默认建议配置为             `STREAM`                       |
| 条件类型                   | SetConditionType     |  否   | ConditionType  | 是否为条件功能单元，取值为： `NONE`、`IF_ELSE`。差异详见[功能单元类型](../../../basic-conception/flowunit.md#功能单元类型)章节。                                                      |
| 输出类型                   | SetOutputType        |  否   | FlowOutputType | 设置是否为扩张或者合并功能单元，取值为: `ORIGIN`、`EXPAND`、`COLLAPSE`。差异详见[功能单元类型](../../../basic-conception/flowunit.md#功能单元类型)章节。                                          |
| 功能单元输入端口           | AddFlowUnitInput     |  是   | FlowUnitInput  | 设置输入端口名和数据存放设备类型， 数据存放设备类型不设置时，默认与功能单元设备类型一致。 **当需要操作数据时，如果前面功能单元输出数据与本功能单元输入端口配置的设备类型不一致时，ModelBox框架会自动搬移至目标设备。**                                            |
| 功能单元输出端口           | AddFlowUnitOutput |  是   | FlowUnitOutput | 设置输出端口，输出数据存放设备类型固定与功能单元设备类型一致。                                               |
| 功能单元配置参数           | AddFlowUnitOption    |  是   | FlowUnitOption | 设置功能单元配置参数，包括参数名，类型，描述等信息。目前用于UI显示。                       |
| 输入内存是否连续           | SetInputContiguous   |  否   | bool           | 是否要求一次输入的一组Buffer内存地址是否连续，默认为`false`。                                     |
| 异常是否可见               | SetExceptionVisible  |  否   | bool           | 本功能单元是否需要捕获前面流程的异常，默认为`false`                                 |

## 功能单元逻辑实现

### 功能单元接口说明

ModelBox框架提供的功能单元开发C++接口如下，开发者按需实现：

| 接口   | 功能说明          | 是否必须          | 使用说明                        |
|-|-|-|-|
| FlowUnit::Open | 功能单元初始化 |  否   | 实现功能单元的初始化，资源申请，配置参数获取等|
| FlowUnit::Close   | 功能单元关闭   |  否  |实现资源的释放 |
| FlowUnit::Process | 功能单元数据处理 |  是 | 实现核心的数据处理逻辑|
| FlowUnit::CudaProcess | cuda类型功能单元数据处理 | 否| 实现cuda类型功能单元核心数据处理逻辑，以替代Process，当功能单元类型为cuda时生效|
| FlowUnit::AscendProcess | ascend类型功能单元数据处理 | 否 |实现ascend类型功能单元核心数据处理逻辑，以替代Process，当功能单元类型为ascend时生效 |
| FlowUnit::DataPre   | 功能单元Stream流开始  |否 | 实现Stream流开始时的处理逻辑，功能单元数据处理类型是`STREAM`时生效  |
| FlowUnit::DataPost | 功能单元Stream流结束 |否|实现Stream流结束时的处理逻辑，功能单元数据处理类型是`STREAM`时生效|

* **功能单元初始化/关闭接口**

  对应需实现的接口为`FlowUnit::Open`、`FlowUnit::Close`，实现样例如下：

  ```c++
  modelbox::Status ExampleFlowUnit::Open(
      const std::shared_ptr<modelbox::Configuration> &opts) {
    // 获取流程图中功能单元配置参数值，进行功能单元的初始化
    auto pixel_format = opts->GetString("pixel_format", "bgr");
    ...
    return modelbox::STATUS_OK;
  }
  ```
  
  ```c++
  modelbox::Status ExampleFlowUnit::Close() {
    // 释放功能单元的公共资源
    ...
    return modelbox::STATUS_OK;
  }
  ```

  Open函数将在图初始化的时候调用，`const std::shared_ptr<modelbox::Configuration> &opts`为流程图Toml配置中功能单元的配置参数，可调用相关的接口获取配置，返回`modelbox::STATUS_OK`，表示初始化成功，否则初始化失败。

* **数据处理接口**

  对应接口为`FlowUnit::Process`, 其为功能单元最核心函数，输入数据的处理、输出数据的构造都在此函数中实现。接口处理流程实现大致如下：

  1. 通过配置的输入输出端口名，从DataContext中获取输入BufferList、输出BufferList对象。
  1. 循环处理每一个输入Buffer数据，默认`STREAM`类型一次只处理一个数据，不必循环。
  1. 业务处理，获取每一个输入Buffer的Meta信息和Data信息，根据需求对输入数据进行处理。
  1. 构造输出Buffer，对每一个输出Buffer数据设置Meta信息和Data信息。
  1. 返回成功后，ModelBox框架将数据发送到后续的功能单元。  

  cpu功能单元的实现样例如下：

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> ctx) {
    // 获取输入输出BufferList对象，"input", "output"为对应功能单元Port名称，可以有多个。
    // 此处的"input"和"output"必须与toml的端口名称一致
    auto input_bufs = ctx->Input("input");
    auto output_bufs = ctx->Output("output");
  
    // 循环处理每个输入数据，并产生相关的输出结果。默认情况一次传递一个buffer进行处理，可以通过
    // input_bufs->Front() 获取。 如果需要batch并发处理则需要修改功能单元数量处理类型为"NORMAL"
    for (auto &input : *input_bufs) {
        // 通过key 获取输入Buffer的Meta信息
        auto input_meta = input->Get("key", "default_value");
        // 获取输入Buffer的Data数据指针，该数据只读只读，且数据已确保在输入设备类型上
        auto input_data = input->ConstData();
        ...
        // 根据当前功能单元设备类型构造buffer
        auto output_buffer = std::make_shared<modelbox::Buffer>(GetBindDevice()); 
        
        // 业务逻辑处理
        ...

        //结果转换成输出Buffer，下面以string转成buffer为例
        std::string test_str = "test string xxx";
        // 申请内存，单位是字节数
        output_buffer->Build(test_str.size());  
        // 获取输出Buffer Data指针
        auto output_data = static_cast<char *>(output_buffer->MutableData());  
        // 拷贝string到buffer中。假设输出为cpu设备，则这里使用cpu内存拷贝
        if(memcpy_s(output_data, output_buffer->GetBytes(), test_str.data(), test_str.size()) != 0 ) {
            MBLOG_ERROR << "cpu memcpy failed, ret " << ret;
            return modelbox::STATUS_FAULT;
        } 
        // 设置输出Buffer Meta
        output_buffer->Set("key", "value");
        // 将输出Buffer放入到输出Bufferlist中
        output_bufs->PushBack(output_buffer);
    }

    return modelbox::STATUS_OK;
  }

  ```

  `FlowUnit::Process`的**返回值说明**如下：
  
  * **STATUS_OK**: 返回成功，将输出Buffer发送到后续功能单元处理。
  * **STATUS_CONTINUE**: 返回成功，暂缓发送输出Buffer的数据。
  * **STATUS_SHUTDOWN**: 停止数据处理，终止整个流程图。
  * **其他**: 停止数据处理，当前数据处理报错。

  <br>

  目前ModelBox支持开发cuda 和 ascend类型的功能单元，与cpu类型不同，cuda和ascend上进行编程存在CUDA Stream、ACL Stream的概念，所以接口上有些差异，新增了`FlowUnit::CudaProcess`、`FlowUnit::AscendProcess`替代`FlowUnit::Process` ， 具体参考下列编程接口：

  ```c++
  modelbox::Status ExampleFlowUnit::CudaProcess(std::shared_ptr<modelbox::DataContext> data_ctx, cudaStream_t stream) {
     // 实现核心业务逻辑。 接口携带cuda stream ，可直接用于调用cuda异步接口。
     // 如果调用ascend同步接口，则需要先调用cudaStreamSynchronize(stream)同步数据。
     ...
    }
  
  modelbox::Status ExampleFlowUnit::AscendProcess(std::shared_ptr<modelbox::DataContext> data_ctx, aclrtStream stream) {
     // 实现核心业务逻辑。 接口携带acl stream ，可直接用于调用acl异步接口。
     // 如果调用cuda同步接口，则需要先调用aclrtSynchronizeStream(stream)同步数据。
     ...
    }
  ```

  更多关于加速设备上的功能单元开发详细说明可参考[多设备开发](../../../other-features/device/device.md)章节和[Ascend](../../../other-features/device/ascend.md)类型、[Nvida CUDA](../../../other-features/device/cuda.md)类型接口说明。

* **Stream流数据开始/结束接口**

  Stream数据流的概念介绍可参考[数据流](../../../basic-conception/stream.md)章节。对应需实现的接口为`FlowUnit::DataPre`、`FlowUnit::DataPost`，此接口针对Stream类型的功能单元生效。使用的典型场景如处理一个视频流时，在视频流开始时会调用`FlowUnit::DataPre`，视频流结束时会调用`FlowUnit::DataPost`。功能单元可以在DataPre阶段初始化解码器，在DataPost阶段关闭解码器，解码器的相关句柄可以设置到DataContext上下文中，在Process阶段使用。
  
  接口处理流程大致如下：

  1. Stream流数据开始时，在DataPre中获取数据流元数据信息，并初始化相关的上下文，使用SetPrivate存储在DataContext中。
  1. 处理Stream流数据时，在Process中，使用GetPrivate获取到上下文对象，并从输入端口中获取输入，处理后，结果设置到输出端口。
  1. Stream流数据结束时，在DataPost中释放相关的上下文信息。

 使用**场景及约束**如下：

  1. `FlowUnit::DataPre`、`FlowUnit::DataPost` 阶段无法操作Buffer数据，仅用于 `FlowUnit::Process`中需要用到的一些资源的初始化，如解码器等。
  1. `FlowUnit::DataPre`、`FlowUnit::DataPost` 不能有长耗时操作，比如文件下载、上传等，会影响并发性能。

  以视频解码为例的样例如下：

  ```c++
  modelbox::Status ExampleFlowUnit::DataPre(std::shared_ptr<modelbox::DataContext> data_ctx) {
    // 初始化Stream流数据处理上下文对象。
    auto decoder = CreateDecoder(stream_meta);
    // 保存流数据处理上下文对象。
    data_ctx->SetPrivate("Decoder", decoder);
    ...
    return modelbox::STATUS_OK;
  }
  
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> ctx) {
    auto inputs = ctx->Input("input");
    auto outputs = ctx->Output("output");

    // 获取流数据处理上下文对象。
    auto decoder = data_ctx->GetPrivate("Decoder");
    // 处理输入数据。
    decoder->Decode(inputs, outputs);
    ...
    return modelbox::STATUS_OK;
  }
  
  modelbox::Status ExampleFlowUnit::DataPost(std::shared_ptr<modelbox::DataContext> data_ctx) {
    // 关闭解码器。
    auto decoder = data_ctx->GetPrivate("Decoder");
    decoder->DestroyDecoder();
    ...
    return modelbox::STATUS_OK;
  }
  ```

### Buffer操作

在实现核心数据逻辑时，需要对Buffer进行操作：获取输入Buffer数据，处理结果转换为输出Buffer往后传递, Buffer拷贝等。Buffer数据包含了Meta数据描述信息和Data数据主体，Buffer的详细介绍看参考基础概念的[Buffer](../../../basic-conception/buffer.md)章节。ModelBox提供了常用的Buffer接口用于完成复杂的业务逻辑。

* **获取输入Buffer信息**

  开发者可以根据功能单元属性配置中的输入端口名称获取输入数据队列BufferList，再获取单个Buffer对象即可获取Buffer的各种属性信息：数据指针、数据大小、Meta字段等等。 此外BufferList也提供了快速获取数据指针的接口，样例如下：

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      // 根据输入端口名称获取输入Buffer队列，输入端口名为"input"
      auto input_bufs = data_ctx->Input("input");
      for (auto i = 0; i < input_bufs->Size(); ++i) {
          // 方式一：先获取Buffer对象，再获取Buffer属性：数据指针、数据大小、Meta字段
          auto buffer = input_bufs->At(i);
          const void* buffer_data1 = buffer->ConstData();
          auto buffer_size = buffer->GetBytes();
          int32_t height;
          auto exists = buffer->Get("height", height);
          if (!exists) {
              MBLOG_ERROR << "meta don't have key height";
              return {modelbox::STATUS_NOTSUPPORT, "meta don't have key height"};
          }

          // 方式二：通过buffer_list访问特定位置的数据指针，buffer_data1和buffer_data2内容相同
          void* buffer_data2 = input_bufs->ConstBufferData(i);
          ...
      }
    }
    ```

* **输入Buffer透传给输出端口**

  此场景是将输入Buffer直接作为输出Buffer向后传递，此时Buffer的数据、Meta等全部属性都将保留。此场景一般用于不需要实际访问数据的功能单元，如视频流跳帧。

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      // 所有输入透传给输出端口，输入端口名为"input", 输出端口名为"output"
      auto input_bufs = data_ctx->Input("input");
      auto output_bufs =  data_ctx->Output("output");
      for (auto &buf: input_bufs) {
          ...
          output_bufs->PushBack(buf);
      }
      return STATUS_OK;
  }
  ```

* **创建输出Buffer**

  数据处理完成后，需要创建输出Buffer并把结果数据填充进输出Buffer，设置Buffer Meta。ModelBox提供多种方式创建Buffer：

  `BufferList::Build` : 一次创建多个指定大小的空Buffer, Buffer类型与当前功能单元硬件类型一致。Buffer Data内容需要单独填充。

  `BufferList::BuildFromHost` : 一次创建多个指定大小的Buffer，Buffer类型为cpu类型，Buffer数据在创建时写入，一次调用完成创建和赋值。

  `BufferList::EmplaceBack` ： 调用时隐式创建Buffer，Buffer类型与当前功能单元硬件类型一致。Buffer数据在调用时写入。一次调用完成创建和赋值，较`BufferList::Build`相比简单。

  `BufferList::EmplaceBackFromHost` ： 调用时隐式创建Buffer，Buffer类型为cpu类型。Buffer数据在调用时写入。

  `Buffer构造函数` ： 直接调用Buffer的构造函数。

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      auto output_bufs = data_ctx->Output("output");
      
      // 方式一 Build：创建当前功能单元硬件类型相同的多个空Buffer，再填充数据
      vector<size_t> data_size_list;
      data_size_list.emplace_back(size1);
      data_size_list.emplace_back(size2);
      output_bufs->Build(data_size_list);
      for (auto i = 0; i < output_bufs->Size(); ++i ) { 
          auto output_buffer = output_bufs->At(0);
          auto output_data = output_buffer->MutableData();
          // 给输出Buffer填充数据
          memcpy_s(output_data, output_buf->GetBytes(), data, data_size);
          // 设置Buffer Meta
          output_buffer->Set("width", width);
          ...
      }
      ... 
      
      //方式二 BuildFromHost：创建cpu类型的多个Buffer并同时填充数据
      vector<size_t> data_size_list{1,1,1};
      vector<uint8_t> data_list{122,123,124}
      output_bufs->BuildFromHost(shape, data.data(), 12);
      ...
      
      // 方式三 EmplaceBack/EmplaceBackFromHost：通过开发者自行创建的设备数据直接创建Buffer
      void* device_ready_data1 ;
      std::shared_ptr<void> device_ready_data2 ;
      void* host_ready_data1 ;
      ...
      //用户数据在设备上，且未通过智能指针管理
      output_bufs->EmplaceBack(device_ready_data1, data_size, [](void*){})
      //用户数据在设备上，通过智能指针管理
      output_bufs->EmplaceBack(device_ready_data2, data_size);
      //用户数据在cpu内存上
      output_bufs->EmplaceBackFromHost(host_ready_data1, data_size);
      ...

      //方法四：先构造Buffer，再放入BufferList
      auto output_buffer = std::make_shared<modelbox::Buffer>(GetBindDevice()); 
      ...
      output_bufs->PushBack(output_buffer);

  }
  ```

* **Buffer的拷贝**

  Buffer的数据拷贝分三种情况：浅拷贝、深拷贝、拷贝Meta。它们的区别如下：

  * **浅拷贝**：接口为Copy，拷贝Meta信息和Data数据指针，源Buffer和目标Buffer共享数据内容。

  * **深拷贝**：接口为DeepCopy，拷贝Meta信息和Data数据内容，源Buffer和目标Buffer数据完全独立。

  * **拷贝Meta**：接口为CopyMeta， 仅拷贝Meta信息，不拷贝Data数据部分。

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      auto input_bufs = data_ctx->Input("input");
      auto output_bufs = data_ctx->Output("output");
      auto buffer = input_bufs->At(0);
  
      // 浅拷贝， buffer和new_buffer 数据指针指向同一份数据
      auto new_buffer = buffer->Copy();
      
      // 深拷贝， buffer和new_buffer 数据指针指向不同数据，数据内容一样
      auto new_deep_buffer = buffer->DeepCopy();
  
      output_bufs->Build({1});
      auto out_buffer = output_bufs->At(0);
      // 仅拷贝Buffer Meta信息， out_buffer和buffer Meta信息完全一致
      out_buffer->CopyMeta(buffer);
      ...
  }
  ```

更多Buffer操作见[API接口](../../../api/c++.md)， Buffer的异常处理见[异常](../../../other-features/exception.md)章节。

### DataContext与SessionContext

功能单元上下文包含：`会话上下文|SessionContext`和`数据上下文|DataContext`

**DataContext 数据上下文**：DataContext是提供给当前功能单元处理数据时的临时获取BufferList
功能单元处理一次Stream流数据，或一组数据的上下文，当数据生命周期不再属于当前功能单元时，DataContext生命周期也随之结束。

  **生命周期**：功能单元内部，从流数据进入功能单元到处理完成。

  **使用场景**：通过DataContext->Input接口获取输入端口BufferList；通过DataContext->Output接口获取输出端口BufferList对象；通过DataContext->SetPrivate接口设置临时对象；DataContext->GetPrivate接口获取临时对象。

**SessionContext 会话上下文**： SessionContext主要供调用图的业务使用，业务处理数据时，设置任务基本状态对象。

  **生命周期**：多功能单元之间生效，任务级别。一次图的输入数据（ExternalData），从数据进入Flow，贯穿整个图，一直到数据处理完成结束。

  **使用场景**：例如HTTP服务同步响应场景，首先接收到HTTP请求后转化成Buffer数据，然后通过ExternalData->GetSessionContext接口获取到SessionContext，接着调用SessionContext->SetPrivate设置响应的回调函数，之后通过ExternalData->Send接口把Buffer数据发送到flow中；经过中间的业务处理功能单元；最后HTTP响应功能单元中在业务数据处理完成后，再调用SessionContext->GetPrivate获取响应回调函数，发送HTTP响应。至此SessionContext也结束。

  DataContext 和 SessionContext提供了如下功能用于复杂业务的开发：

* **通过DataContext获取输入输出BufferList**

  通过输入输出端口名获取输入以及输出数据

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      // 通过端口输入输出端口名获取BufferList，端口名分别为input, output
      auto input_bufs = data_ctx->Input("input");
      auto output_bufs = data_ctx->Output("output");
      ...
  }
  ```

* **通过DataContext保存本功能单元Stream流级别数据**

  对于Stream流的一组数据，在本功能单元内DataPre、每次Process、 DataPost接口内可以通过SetPrivate接口设置数据来保存状态和传递信息，通过GetPrivate获取数据。如DataPre和Process间的数据传递，上一次Process和下一次Process间的数据传递。具体使用样例如下：

  ```c++
  modelbox::Status ExampleFlowUnit::DataPre(std::shared_ptr<modelbox::DataContext> data_ctx) {
      // 保存Stream流级别上下文对象。
      data_ctx->SetPrivate("key", value);
      ...
      return modelbox::STATUS_OK;
      }
  
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      auto inputs = ctx->Input("input");
      auto outputs = ctx->Output("output");
  
      // 获取Stream流级别上下文对象。
      auto param = data_ctx->GetPrivate("key");
      ...
      // 保存Stream流级别上下文对象。
      data_ctx->SetPrivate("key", value);
      ...
      return modelbox::STATUS_OK;
  }
  
  modelbox::Status ExampleFlowUnit::DataPost(std::shared_ptr<modelbox::DataContext> data_ctx) {
      // 获取Stream流级别上下文对象。
      auto decoder = data_ctx->GetPrivate("key");
      ...
      return modelbox::STATUS_OK;
  }
  ```

* **通过DataContext获取输入输出端口Meta信息**
  
  除了Buffer外，开发者可以通过输入输出端口Meta传递信息，前一个功能单元设置输出Meta，后面功能单元获取输入Meta。端口的Meta信息传递不同与Buffer Meta，Buffer Meta是数据级别， 而前者是Stream流级别。

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      // 获取输入端口Meta里的字段信息
      auto input_meta = data_ctx->GetInputMeta("input");
      auto value = std::static_pointer_cast<std::string>(input_meta->GetMeta("key"));
      ...
      
      // 设置Meta到输出端口
      auto output_meta = std::make_shared<modelbox::DataMeta>();
      output_meta->SetMeta("key", value);
      data_ctx->SetOutputMeta("output", output_meta);
      return modelbox::STATUS_OK;
  }
  ```

* **通过DataContextStream判断流异常**

  判断Stream流数据中处理是否存在异常，Stream流包含多个Buffer时，只要有一个Buffer存在异常即认为Stream流存在异常。

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      auto res = data_ctx->HasError();
      ...
      return modelbox::STATUS_OK;
  }
  ```

* **通过DataContext发送事件**

  在开发功能单元时，存在通过功能单元自驱动的场景。如视频解码时，在输入一次视频地址数据后，后续在没有数据驱动的情况下需要反复调度解封装功能单元。 此时需要通过在功能单元中发送事件，来驱动调度器在没有数据的情况下继续调度该功能单元。

  ```c++
  modelbox::Status ExampleFlowUnit::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      ...
      auto event = std::make_shared<FlowUnitEvent>();
      data_ctx->SendEvent(event);

      //返回值需要是 STATUS_CONTINUE，已保证本功能单元继续调度
      return STATUS_CONTINUE;
  }
  ```

* **通过SessionContext存储任务级别全局数据**

  存储任务的全局变量，可用于在多个功能单元之间共享数据。SessionContext的全局数据的设置和获取方式如下：

  ```c++
  modelbox::Status ExampleFlowUnit1::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      auto session_cxt = data_ctx->GetSessionContext();
      session_cxt->SetPrivate("key", value);
      ...
      return modelbox::STATUS_OK;
  }
  ```

  ```c++
  modelbox::Status ExampleFlowUnit2::Process(std::shared_ptr<modelbox::DataContext> data_ctx) {
      auto session_cxt = data_ctx->GetSessionContext();
      auto value = session_cxt->GetPrivate("key");
      ...
      return modelbox::STATUS_OK;
  }
  ```

## 功能单元编译运行

ModelBox框架C++工程统一使用CMake进行编译，通过命令行或者可视化UI创建的功能单元中默认包含CMakeLists.txt文件，主要功能如下：

1. 设置功能单元名称
1. 链接功能单元所需头文件
1. 链接功能单元所需库
1. 设置编译目标为动态库
1. 指定功能单元安装目录

功能单元编译生成的so命名需要以**libmodelbox-**开头，否则ModelBox无法扫描。
通常情况开发cpu业务功能单元，开发者无需修改CMakeLists.txt即可完成编译，当存在引入第三方库时、设置cuda/ascend类型、修改编译选项等等诉求时需要自行修改。生成的so安装路径一般也无需修改，如果开发者需要改动，则需要将路径添加到图的扫描路径`driver.dir`中。

## 功能单元功能测试

ModelBox框架提供了基于Gtest的单元测试框架， 开发者可以编写测试用例进行功能单元的基础功能测试。 测试用例需要放在 `$Project/test/flowunit/`目录下，测试用例基本写作基本步骤如下：

1. 构建流程图并运行，流程图的开始和结尾通过input、output端口连接，用于图与外部程序的数据交互。中间业务部分可以是单个功能单元，也可以是多个功能单元。
1. 构造输入Buffer并发送至流程图的input端口
1. 通过流程图的output端口获取输出结果，并进行预期校验

样例如下：

```c++
class ExampleFlowUnitTest : public testing::Test {
 public:
  ExampleFlowUnitTest() : mock_modelbox_(std::make_shared<MockModelBox>()) {}

 protected:
  virtual void SetUp(){};
  virtual void TearDown() { mock_modelbox_->Stop(); };
  std::shared_ptr<MockModelBox> GetMockModelbox() { return mock_modelbox_; }

 private:
  std::shared_ptr<MockModelBox> mock_modelbox_;
};

TEST_F(ExampleFlowUnitTest, TestCase1) {
  // 构建流程图
  const std::string test_lib_dir = TEST_LIB_DIR;
  std::string toml_content = R"(
            [log]
            level="DEBUG"
            [driver]
            skip-default=false
            dir=[")" + test_lib_dir +
                             "\"]\n    " +
                             R"([graph]
            graphconf = '''digraph demo {                                                                            
                input1[type=input]
                resize_test[type=flowunit, flowunit=resize_test, device=cpu, deviceid=0, label="<in_1> | <out_1>", image_width=128, image_height=128,batch_size=5]
                output1[type=output]                                
                input1 -> resize_test:in_1 
                resize_test:out_1 -> output1                                                                      
                }'''
            format = "graphviz"
        )";
  // 运行流程图
  auto mock_modelbox = GetMockModelbox();
  auto ret = mock_modelbox->BuildAndRun("graph_name", toml_content, 10);
  EXPECT_EQ(ret, STATUS_SUCCESS);

  // 构造输入Buffer，包含Meta数据描述信息和Data数据主体
  auto ext_data = mock_modelbox->GetFlow()->CreateExternalDataMap();
  EXPECT_NE(ext_data, nullptr);
  auto buffer_list = ext_data->CreateBufferList();
  EXPECT_NE(buffer_list, nullptr);
  auto img = cv::imread(std::string(TEST_ASSETS) + "/test.jpg");
  buffer_list->Build({img.total() * img.elemSize()});
  auto buffer = buffer_list->At(0);
  buffer->Set("width", img.cols);
  buffer->Set("height", img.rows);
  buffer->Set("width_stride", img.cols * 3);
  buffer->Set("height_stride", img.rows);
  buffer->Set("pix_fmt", std::string("bgr"));
  memcpy(buffer->MutableData(), img.data, img.total() * img.elemSize());

  // 发送Buffer到图的input端口，端口名与流程图中input端口名一致
  auto status = ext_data->Send("input1", buffer_list);
  EXPECT_EQ(status, STATUS_OK);
  status = ext_data->Shutdown();
  EXPECT_EQ(status, STATUS_OK);

  // 通过output端口等待获取输出Buffer，端口名与流程图中output端口名一致
  std::vector<std::shared_ptr<BufferList>> output_buffer_lists =
      mock_modelbox->GetOutputBufferList(ext_data, "output1");

  // 校验输出结果
  EXPECT_EQ(output_buffer_lists.size(), 1);
  auto output_buffer_list = output_buffer_lists[0];
  EXPECT_EQ(output_buffer_list->Size(), 1);
  auto output_buffer = output_buffer_list->At(0);
  int32_t width;
  int32_t height;
  auto exists = output_buffer->Get("width", width);
  EXPECT_EQ(exists, true);
  exists = output_buffer->Get("height", height);
  EXPECT_EQ(exists, true);
}
```

测试用例的运行可以通过命令行，也可以通过vscode等IDE功能运行，方便调试。具体运行命令如下：  

```shell
$Project/build/test/unit/unit --gtest_filter=ExampleFlowUnitTest.*
```
