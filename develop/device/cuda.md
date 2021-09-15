# Nvidia Cuda显卡

Nvidia Cuda支持stream并发编程，什么是stream可参考[此处](https://developer.download.nvidia.com/CUDA/training/StreamsAndConcurrencyWebinar.pdf)

ModelBox为更好的支持Stream并发编程，默认情况下，ModelBox的Cuda接口全部采用Stream模式，开发者需要在编程时，使用Cuda的Stream接口以提升性能。

## Cuda流单元接口

ModelBox框架会自动管理Stream，开发流单元时，开发者可以通过process的入参获取到Stream，之后可以用于Cuda接口的调用中。

在实现流单元之前，cuda相关的流单元，需要从`CudaFlowUnit`派生，并实现`CudaProcess`接口。

```c++
class SomeCudaFlowUnit : public modelbox::CudaFlowUnit {
 public:
  SomeCudaFlowUnit() = default;
  virtual ~SomeCudaFlowUnit() = default;

  // 数据处理接口，需要实现CudaProcess，第二个参数为Cuda Stream。
  virtual modelbox::Status CudaProcess(std::shared_ptr<modelbox::DataContext> data_ctx,cudaStream_t stream);
};
```

除CudaProcess以外，其他接口和通用流单元一致，CudaProcess接口如下：

```c++
modelbox::Status ColorTransposeFlowUnit::CudaProcess(
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

数据处理时，Stream会自动由ModelBox框架生成，再调用Cuda接口时，直接使用此Stream对象即可。
