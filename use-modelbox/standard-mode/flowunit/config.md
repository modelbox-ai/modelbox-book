# 配置类功能单元

本章节介绍推配置类功能单元的开发流程。在AI应用开发时，存在较多处理过程完全一样，但输入参数存在差异的处理，如yolo检测的后处理。为了减少开发者开发工作，Modelbox提供了配置类功能单元，完成特定功能。用户只需填写配置文件即可完成功能单元开发。下面以yolo功能单元为例介绍配置类功能单元开发流程。

## 配置类功能单元创建

Modelbox提供了多种方式进行功能单元的创建，以yolo为例：

* 通过UI创建
  
  可参考可视化编排服务的[任务编排页面](../../../plugins/editor.md#功能单元)章节操作步骤。

* 通过命令行创建

  ModelBox提供了模板创建工具，可以通过**ModelBox Tool**工具产生python功能单元的模板，具体的命令为

  ```shell
  modelbox-tool template -flowunit -project-path [project_path] -name [flowunit_name] -lang yolo -virtual-type [type] -input name=in1,device=cpu -output name=out1 
  ```

创建完成的C++功能单元目录结构如下：

```shell
[flowunit-name]
     |---CMakeList.txt           # 用于CPACK 打包 
     |---[flowunit-name].toml    # 功能单元属性配置文件
```

## 功能单元属性配置

每种配置类功能单元是完成特定功能，所以他们的配置参数各不相同，具体参数配置可参考预置功能单元中[配置类](../../../flowunits/flowunits-virtual.md)章节。

## 功能单元调试运行

配置类功能单元无需编译，通常情况下调试阶段可以将此功能单元所在的文件夹路径配置到流程图的扫描路径driver.dir中，再通过Modelbox-Tool 启动流程图运行，流程图启动时会扫描并加载功能单元。
