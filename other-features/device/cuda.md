# Nvidia CUDA加速卡

Nvidia CUDA支持Stream并发编程，什么是Stream可参考[此处](https://developer.download.nvidia.com/CUDA/training/StreamsAndConcurrencyWebinar.pdf)

ModelBox为更好的支持Stream并发编程，默认情况下，ModelBox的CUDA接口全部采用Stream模式，开发者需要在编程时，使用CUDA的Stream接口以提升性能。

## CUDA功能单元接口

ModelBox框架会自动管理Stream，开发功能单元时，开发者可以通过process的入参获取到Stream，之后可以用于CUDA接口的调用中。

在实现功能单元之前，cuda类型的功能单元，需要从`CudaFlowUnit`派生，并实现`CudaProcess`接口。

```c++
#include "modelbox/device/cuda/device_cuda.h"

class ExampleCudaFlowUnit : public modelbox::CudaFlowUnit {
 public:
  ExampleCudaFlowUnit() = default;
  virtual ~ExampleCudaFlowUnit() = default;

  // 数据处理接口，需要实现CudaProcess，第二个参数为CUDA Stream。
  virtual modelbox::Status CudaProcess(std::shared_ptr<modelbox::DataContext> data_ctx,cudaStream_t stream);
};
```

除CudaProcess以外，其他接口和通用功能单元一致，CudaProcess接口如下：

```c++
modelbox::Status ExampleCudaFlowUnit::CudaProcess(
    std::shared_ptr<modelbox::DataContext> data_ctx, cudaStream_t stream) {
  auto inputs = ctx->Input("input");
  auto outputs = ctx->Output("output");

  // 申请内存
  std::vector<size_t> data_size_list(1, 2, 3);
  outputs->Build(data_size_list);

  // 循环处理每个输入数据，并产生相关的输出结果。
  for (size_t i = 0; i < inputs->Size(); ++i) {
      // 获取数据元数据信息
      auto meta = inputs[i].Get("Meta", "Default");

      // 获取输入，输出的内存指针。输入为const只读数据，输出为可写入数据。
      auto input_data = inputs[i].ConstData();
      auto output_data = outputs[i].MutableData();

      // 使用Stream处理数据
      // kernel3 <<< grid, block, 0, stream >>> ( …, … ) ;

      // 设置输出Meta
      outputs[i].Set("Meta", "Meta Data");
  }

  return modelbox::STATUS_OK;
}
```

由于不确定输入数据是否是异步执行的数据，**如果CudaProcess里需要调用ACL同步接口，则需要在调用前，先调用`cudaStreamSynchronize(stream)`进行数据同步**。

```c++
modelbox::Status ExampleCudaFlowUnit::CudaProcess(
    std::shared_ptr<modelbox::DataContext> data_ctx, cudaStream_t stream) {
  auto inputs = ctx->Input("input");
  auto outputs = ctx->Output("output");

  // 同步数据
  cudaStreamSynchronize(stream);

  // 申请内存
  std::vector<size_t> data_size_list;
  for (auto &input : *inputs) {
    data_size_list.push_back(input->GetBytes());
  }
  outputs->Build(data_size_list);

  // 循环处理每个输入数据，并产生相关的输出结果。
  for (size_t i = 0; i < inputs->Size(); ++i) {
      // 获取输入，输出的内存指针。输入为const只读数据，输出为可写入数据。
      auto input_data = inputs[i].ConstData();
      auto output_data = outputs[i].MutableData();
      // 同步拷贝输入到输出
      cudaMemcpy(output_data, input_data, inputs[i]->GetBytes(), cudaMemcpyDeviceToDevice);
  }

  return modelbox::STATUS_OK;
}
```

数据处理时，Stream会自动由ModelBox框架生成，再调用CUDA接口时，直接使用此Stream对象即可。
