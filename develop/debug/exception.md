# 异常处理

开发者在运行流程图和开发流程图的过程当中，需要针对flowunit的情况返回异常，能够可以在其他业务流程中捕获当前异常进行自定义处理，modelbox即可提供该场景下异常捕获处理的能力

## 异常处理样例

+ 在自定义的flowunit当中，只需要在process处理过程当中针对需要处理的异常情况返回Status状态，如下例所示

```c++
   Status Example::Process(std::shared_ptr<DataContext> data_ctx) {
       if (exception) {
           return {STATUS_FAULT, "the desc you want to catch."};
       }
   }
```

+ 在自定义的需要捕获的flowunit当中，需要做如下两件事：

1. 定义该flowunit的描述属性为ExceptionVisible(true)

```c++
   MODELBOX_FLOWUNIT(ExampleFlowUnit, desc) {
      ...
      desc.SetExceptionVisible(true);
   } // 若为c++ flowunit
```

```toml
   exception_visible = true # 若为python， 则在定义python的toml配置文件当中
```

1. 在获取flowunit的process当中获取exception error.

```c++
   Status GetException::Process(std::shared_ptr<DataContext> data_ctx) {
       if (data_ctx->HasError()) {
           auto exception = data_ctx->GetError();
           auto exception_desc = exception->GetDesc();
           MBLOG_ERROR << "error is: " << exception_desc;
       }
   } // exception_desc 即为 "the desc you want to catch"
```

```python
   def process(self, data_ctx):
       if data_ctx.has_error():
           exception = data_ctx.get_error()
           exception_desc = exception.get_description()
           print("error is: " + exception_desc)
    # exception_desc 即为 "the desc you want to catch"
```

## 异常使用注意事项

+ 不要在if-else、loop当中以及拆分合并的flowunit中捕获异常
