# ModelBox运行

通常情况下，ModelBox可以看作是一个应用服务。当需要运行ModelBox时，需要启动ModelBox Server服务。ModelBox Server是最基本也是最重要的服务，ModelBox Server提供基础配置流程图的加载、可视化编排UI服务、流程图Restful API等能力。开发者只需将[flow流程图](../flow/flow.md)配置文件放到指定的目录下，即可实现flow作为服务的功能。

## 启动服务

有两种方式启动ModelBox服务：

### 通过modelbox命令启动

  此方法可在运行镜像启动时添加如下启动脚本/命令，来执行如下命令启动ModelBox服务：

  ```shell
  modelbox -c [path_to_modelbox_conf] -fV
  ```

  通过modelbox命令可启动ModelBox服务进程，常用参数说明如下：
  
  `-c`可指定`modelbox.conf`配置文件，具体参数配置可参考[服务配置](./pack.md#ModelBox配置)章节；

  `-f`表示modelbox进程在前台执行；

  `-V`表示将日志打印到屏幕；

  更多命令可通过`modelbox -h`查询。

### 通过systemd启动

  此方法在运行镜像启动时会默认通过systemd启动ModelBox服务，默认读取的ModelBox配置路径为`/usr/local/etc/modelbox/modelbox.conf`，开发者可替换/修改该的配置文件即可。
  
  ModelBox Server服务使用标准的systemd unit管理，启动管理服务，使用systemd命令管理。

  当运行环境支持Systemd时，可通过如下命令对ModelBox服务进行操作：
  
  ```shell
  sudo systemctl status modelbox.service：查看ModelBox服务的状态。
  sudo systemctl stop modelbox.service：停止ModelBox服务。
  sudo systemctl start modelbox.service：启动ModelBox服务。
  sudo systemctl restart modelbox.service：重启ModelBox服务。
  ```
  
  如无systemd管理机制时，可以使用SysvInit命令管理ModelBox服务，命令如下：
  
  ```shell
  sudo /etc/init.d/modelbox [start|status|stop]
  ```
  
  此方式相比systemd，缺失了进程的监控，所以建议优先使用systemd启动ModelBox服务。
  
  如需要监控机制，可以使用ModelBox Manager来管理，可以从ModelBox Manager来启动ModelBox服务，命令如下
  
  ```shell
  sudo /etc/init.d/modelbox-manager [start|status|stop]
  ```

- ModelBox服务启动参数配置

  ModelBox Server服务启动参数配置项目如下：

| 配置项          | 配置功能                                                                                                                   |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `MODELBOX_OPTS` | ModelBox服务启动时会加载该变量的内容作为启动参数。如果开发者需要重新指定其他的ModelBox服务运行配置时，可修改该变量的值实现。 |
