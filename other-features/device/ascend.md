# Huawei Ascend加速卡

Huawei Ascend ACL支持接口编程，ACL接口相关的介绍，请点击[此处](https://support.huawei.com/enterprise/en/doc/EDOC1100155021/50a12c70/acl-api-reference)

ModelBox为更好的支持Stream并发编程，默认情况下，ModelBox的Ascend ACL接口全部采用Stream模式，开发者需要在编程时，使用Ascend ACL的Stream接口以提升性能。

## Ascend ACL功能单元接口

ModelBox框架会自动管理Stream，开发功能单元时，开发者可以通过Process的入参获取到Stream，之后可以用于ACL接口的调用中。

在实现功能单元之前，Ascend ACL相关的功能单元，需要从`AscendFlowUnit`派生，并实现`AscendProcess`接口。

```c++
#include <modelbox/device/ascend/device_ascend.h>

class SomeAscendFlowUnit : public modelbox::AscendFlowUnit {
 public:
  SomeAscendFlowUnit() = default;
  virtual ~SomeAscendFlowUnit() = default;

  // 数据处理接口，需要实现AscendProcess，第二个参数为Ascend ACL Stream。
  virtual modelbox::Status AscendProcess(std::shared_ptr<modelbox::DataContext> data_ctx, aclrtStream stream);
};
```

除AscendProcess以外，其他接口和通用功能单元一致，AscendProcess接口如下：

```c++
modelbox::Status AscendFlowUnit::AscendProcess(
    std::shared_ptr<modelbox::DataContext> data_ctx, aclrtStream stream) {
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
      // aclmdlExecuteAsync(model_id_, input.get(), output.get(), stream);

      // 设置输出Meta
      outputs[i].Set("Meta", "Meta Data");
  }

  return modelbox::STATUS_OK;
}
```

```c++
modelbox::Status AscendFlowUnit::AscendProcess(
    std::shared_ptr<modelbox::DataContext> data_ctx, aclrtStream stream) {
  auto inputs = ctx->Input("input");
  auto outputs = ctx->Output("output");

  // 同步Stream
  aclrtSynchronizeStream(stream);

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
      aclrtMemcpy(output_data, outputs[i]->GetBytes(), input_data, inputs[i]->GetBytes(), aclrtMemcpyKind::ACL_MEMCPY_DEVICE_TO_DEVICE);
  }

  return modelbox::STATUS_OK;
}
```

数据处理时，Ascend Stream会自动由ModelBox框架生成，再调用Ascend ACL接口时，直接使用此Stream对象即可。
