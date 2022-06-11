# 流单元数据处理

这是编写自定义流单元当中处理数据的部分的说明

## buffer/buffer_list接口的使用场景

真正需要使用buffer/buffer_list接口是在编写自定义流单元当中需要处理数据时

### 流单元输入数据的获取, 输出数据构造

```python
    
    # numpy
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("input")
        output_bufs = data_ctx.output("output")
        for input_buf in input_bufs:
            # image即为从buffer当中构建的对象
            image = np.array(input_buf)
            ...
            empty_np = np.array([])
            # 创建输出buffer，并且push给output_bufs
            out_buf = self.create_buffer(empty_np)
            output_bufs.push_back(out_buf)

        return modelbox.Status()
```

```python

    # string
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("input")
        output_bufs = data_ctx.output("output")
        for input_buf in input_bufs:
            # 若input_buf为string对象，ss即为ss
            ss = input_buf.as_object()
            ...
            ss += " response"
            # 创建输出buffer，并且push给output_bufs
            out_buf = self.create_buffer(ss)
            output_bufs.push_back(out_buf)

        return modelbox.Status()
```

### buffer中获取传递来的属性(meta)值

```python
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("input")
        output_bufs = data_ctx.output("output")
        for input_buf in input_bufs:
            res = input_buf.set("test", "test")
            print(test)
            print(new_buffer.get("test"))
            

        return modelbox.Status()
```

### buffer的error接口

```python
    def Process(self, data_ctx):
        input_bufs = data_ctx.input("input")
        output_bufs = data_ctx.output("output")
        for input_buf in input_bufs:
            res = input_buf.has_error()
            if res:
                error = input_buf.get_error()
                error_code = input_buf.get_error_code()
                error_msg = input_buf.get_error_msg()

            
        ...
        return modelbox.Status()

```

### buffer的其他可能接口以及用法

#### buffer的copy所有meta值接口

```python
    ...
    def Process(self, data_ctx):
        buf_list = data_ctx.input("input")
        for buf in buf_list:
            infer_data = np.ones((5,5))
            new_buffer = self.create_buffer(infer_data)
            status = new_buffer.copy_meta(buf)
            ...
        
        return modelbox.Status()
```
