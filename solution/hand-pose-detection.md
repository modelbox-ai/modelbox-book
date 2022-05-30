# 手势识别

手势识别解决方案是ModelBox提供可直接调用的API，用户启动手势识别solution后，push进去需要推理的图片数据，会将推理结果返回给用户。检测效果如下图所示：

![hand_pose_result](../assets/images/figure/solution/hand_pose_result.jpg)

## 输入

输入类型为为`ModelBox::Buffer`，其中包含data与meta两种数据，具体要求如下：

- data：图片二进制数据

- meta：无要求

## 输出

输出类型为为`ModelBox::Buffer`，其中包含data与meta两种数据，具体如下：

- data：检测后图片，若检测到手，则画出手的框与手指连线；若未检测到手，则为原图。

- meta：
  - width：图片宽度。
  - height：图片高度。
  - channel：图片通道数。
  - pix_fmt：图片格式。
  - has_hand：值判断是否有检测到手，True为检测到有手，False为未检测到手。为True才会有bboxes与hand_pose参数。
  - bboxes：检测到手的box坐标。
  - hand_pose：检测到手指位置坐标，每只手5根手指，每根手指3个关键点坐标。

## 获取方法

可以通过下面两种方式获取：

- 安装包下载：进入[下载链接](http://download.modelbox-ai.com/solutions/hand_pose_detection/)，根据系统选择对应的版本进行下载到[ModelBox镜像](../environment/container-usage.md#支持容器列表)中，直接安装后可调用相关接口可以运行。

- 源码编译：进入解决方案[代码仓](https://github.com/modelbox-ai/modelbox-solutions)，克隆代码仓到[ModelBox开发镜像](../environment/container-usage.md#支持容器列表)中，新建build目录后，执行`make package hand_pose_detection`可得到安装包。

## 使用样例

### C++样例

- 头文件

  ```cpp
  #include <modelbox/solution.h>
  #include <modelbox/flow.h>
  ```

- 主函数

  ```cpp
  // 初始化solution
  ModelBoxLogger.GetLogger()->SetLogLevel  modelbox::LogLevel::LOG_INFO);
  modelbox::Solution solution_test("hand_pose_detection");
  auto flow = std::make_shared<modelbox::Flow>();
  flow->Init(solution_test);
  flow->Build();
  if (!flow->RunAsync()) {
    MBLOG_ERROR << "flow run failed";
  }
  MBLOG_INFO << "build hand_pose detection solution success";

  // 创建输入输出句柄
  auto ext_data = flow->CreateExternalDataMap();
  if (ext_data == nullptr) {
    MBLOG_ERROR << "create external data map failed.";
    return -1;
  }
  auto input_bufs = ext_data->CreateBufferList();

  // push输入数据
  std::string test_file = "path_to_test_image";
  if (!BuildInputData(test_file, input_bufs)) {
    return -1;
  }

  if (!ext_data->Send("input", input_bufs)) {
    MBLOG_ERROR << "send data to input failed.";
    return -1;
  }

  // 获取推理结果
  RecvExternalData(ext_data);

  // 关闭输入输出句柄
  if (!ext_data->Shutdown()) {
    MBLOG_ERROR << "shutdown external data failed.";
    return -1;
  }
  ```

- 创建输入

  ```cpp
  modelbox::Status BuildInputData(const std::string &img_path, std::shared_ptr<modelbox::BufferList> &input_bufferlist) {
    FILE *pImg = fopen(img_path.c_str(), "rb");
    if (pImg == nullptr) {
      MBLOG_ERROR << "file open failed, file path: " << img_path;
      return modelbox::STATUS_FAULT;
    }
  
    fseek(pImg, 0, SEEK_END);
    auto fSize = ftell(pImg);
    rewind(pImg);

    input_bufferlist->Build({(size_t)fSize});
    input_bufferlist->EmplaceBack(pImg, fSize);
  
    fclose(pImg);
    return modelbox::STATUS_SUCCESS;
  }
  ```

- 获取输出

  ```cpp
  modelbox::Status RecvExternalData  (std::shared_ptr<modelbox::ExternalDataMap> ext_data) {
    modelbox::OutputBufferList map_buffer_list;
    // 接收数据
    while (true) {
      auto status = ext_data->Recv(map_buffer_list);
      if (status != modelbox::STATUS_SUCCESS) {
        if (status == modelbox::STATUS_EOF) {
          // 数据处理结束
          MBLOG_INFO << "stream data is EOF, stop recv output buffer";
          break;
        }
        // 处理出错，关闭输出。
        auto error = ext_data->GetLastError();
        ext_data->Close();
        MBLOG_ERROR << "Recv failed, " << status << ", error:" <<   error->GetDesc();
        break;
      }
      // 处理结果数据
      auto buffer_list = map_buffer_list["output"];
      ProcessOutputData(buffer_list);
    }

    return modelbox::STATUS_OK;
  }
  ```

  ```cpp
  void ProcessOutputData(std::shared_ptr<modelbox::BufferList> &output_buffer_list) {
    for (auto &buffer : *output_buffer_list) {
      bool has_hand{false};
      buffer->Get("has_hand", has_hand);
      MBLOG_INFO << "has hand: " << has_hand;

      int32_t width, height;
      buffer->Get("height", height);
      buffer->Get("width", width);
      cv::Mat image(height, width, CV_8UC3);
      memcpy_s(image.data, image.total() * image.elemSize(),
              buffer->ConstData(), buffer->GetBytes());
      cv::imwrite("path_to_save_image", image);
    }
  }
  ```
