# modelbox.Log

|函数|作用|
|-|-|
|[reg](#modelboxlogreg)|注册log的回调函数|
|[set_log_level](#modelboxlogsetloglevel)|设置log的日志级别|
|[print](#modelboxlogprint)|打印日志|
|[print_ext](#modelboxlogprintext)|打印带有额外信息的日志|
---

## modelbox.Log.reg

注册一个log的回调函数。

**args:**  

* **Callable** (python function)  —— 注册的Python回调函数Callable[[Level level, str file, int lineno, str func, str msg], None]

**return:**  

无

## modelbox.Log.set_log_level

设置log组件的日志级别。

**args:**  

* **level** (modelbox.Log.Level) ——  日志级别

**return:**  

无

## modelbox.Log.print

打印日志。

**args:**  

* **level** (modelbox.Log.Level) ——  日志级别
* **msg** (str) ——  打印的日志

**return:**  

无

## modelbox.Log.printExt

打印带有额外信息的日志

**args:**  

* **level** (modelbox.Log.Level) ——  日志级别
* **file** (str) ——  文件的路径  
* **lineno** (str) ——  行号  
* **func** (python function) ——  日志的回调函数  
* **msg** (str) ——  日志信息  

**return:**  

无

**example:**  

```python
   import modelbox
   import inspect
   import os
   import datetime

   def LogCallback(level, file, lineno, func, msg):
    print("[{time}][{level}][{file}:{lineno}] {msg}".format(
        time=datetime.datetime.now(), level=level,
        file=file, lineno=lineno, msg=msg
    ))


   def RegLog(log):
      log.reg(LogCallback)
      log.set_log_level(modelbox.Log.Level.INFO)

   if __name__ == "__main__":
      log = modelbox.Log()
      RegLog(log)
      log.print(modelbox.Log.Level.INFO, "test print")

      frame = inspect.currentframe()
      info = inspect.getframeinfo(frame)

      log.print_ext(modelbox.Log.Level.INFO, os.path.basename(info.filename),
                            info.lineno + 2, info.function, "test print_ext")

      # 推荐用法
      modelbox.info("test_info")
      modelbox.warn("test_warn")
      modelbox.error("test_error")

```

**result:**  

> [2021-12-13 17:45:47.614834][Level.INFO][test.py:20] test print  
> [2021-12-13 17:45:47.615028][Level.INFO][test.py:25] test print_ext  
> [2021-12-13 19:39:54.994327][Level.INFO][test.py:28] test_info  
> [2021-12-13 19:39:54.994454][Level.WARN][test.py:29] test_warn  
> [2021-12-13 19:39:54.994601][Level.ERROR][test.py:30] test_error  

## modelbox.Log.Level

log level分为以下几种级别

modelbox.Log.Level.DEBUG  
modelbox.Log.Level.INFO  
modelbox.Log.Level.ERROR  
modelbox.Log.Level.WARN
