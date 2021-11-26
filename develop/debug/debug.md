# 调试

ModelBox提供了多种调试方法，包含了业务运行，性能，和代码的调试。

## 各个组件调试方法

各个组件的调试方法参考下表：

|语言|组件|调试方法|
|--|--|--|
|c++|ModelBox套件|编译[debug版本](../../compile/compile.md#编译和安装)，安装并配置GDB，日志。
|c++|自开发服务|编译[debug版本](../../compile/compile.md#编译和安装)，安装并配置GDB，日志。
|c++|功能单元|编译[debug版本](../../compile/compile.md#编译和安装)，安装并配置GDB，日志，[Profiling](../../develop/debug/profiling.md)。
|python|功能单元|PDB，日志，[Profiling](../../develop/debug/profiling.md)。

上述表格中，使用GDB、PDB调试的，可以配合IDE完成。

## 调试指导

|调试方法|说明|连接|
|--|--|--|
|代码调试|代码级别的调试方法，主要使用现有的调试工具，IDE进行调试。|[指导](code-debug.md)|
|运行调试|使用运行日志，业务代码使用log类函数打印相关的日志。|[指导](log.md)|
|性能调试|对图的执行进行数据打点，并输出甘特图供性能分析调试。|[指导](profiling.md)|
|异常配置|对自定义flowunit产生的异常捕捉|[指导](exception.md)|