# modelbox.Status

|函数|作用|
|-|-|
|[构造方法](#构造方法)|构造status对象|
|[code](#modelboxstatuscode)|status的code码|
|[str_code](#modelboxstatusstrcode)|status的code码的描述|
|[StatusCode](#modelboxstatusstatuscode)|status的状态码|
|[set_errormsg](#modelboxstatusseterrormsg)|status设置错误信息|
|[errormsg](#modelboxstatuserrormsg)|status获取错误信息|
|[wrap_errormsgs](#modelboxstatuswraperrormsgs)|status获取链式的错误信息|
|[unwrap](#modelboxstatusunwrap)|status解链式status对象|
---

## 构造方法

构造modelbox.Status对象。

### modelbox.Status(status_code)

**args:**  

* **code** (modelbox.Status.StatusCode) —— 从StatusCode创建Status

### modelbox.Status(success)

**args:**

* **success** (bool)  —— 从bool创建Status

### modelbox.Status(code, errmsg)

**args:**

* **code** (modelbox.Status.StatusCode)  —— modelbox的状态码  
* **errmsg** (str) ——  错误的信息

### modelbox.Status(status, errmsg)

* **status** (modelbox.Status)  —— modelbox的状态  
* **errmsg** (str) ——  错误的信息

**return:**  

modelbox.Status

****str**:**  

"code: " + StrCode() + ", errmsg: " + errmsg_

****bool**:**  

bool(status)

**example:**  

```python
   import modelbox

   status = modelbox.Status()
   print(status)
   status1 = modelbox.Status(modelbox.Status.StatusCode.STATUS_CONTINUE)
   print(status1)
   status2 = modelbox.Status(False)
   print(status2)
   status3 = modelbox.Status(modelbox.Status.StatusCode.STATUS_CONTINUE, "continue")
   print(status3)
   status4 = modelbox.Status(status2, "continue")
   print(status4)
   print(bool(status))
  
```

**result:**  

> Success  
> Continue operation  
> Fault  
> code: Continue operation, errmsg: continue  
> code: Fault, errmsg: continue  
> True

## modelbox.Status.code

获取status的状态信息。

**args:**  

无

**return:**  

modelbox.StatusCode

**example:**  

```python
   import modelbox

   status = modelbox.Status()
   print(status.code())
  
```

**result:**  

> StatusCode.STATUS_SUCCESS

## modelbox.Status.str_code

获取status的状态信息字符串。

**args:**  

无

**return:**  

str

**example:**  

```python
   import modelbox

   status = modelbox.Status()
   print(status.str_code())
  
```

**result:**  

> Success

## modelbox.Status.StatusCode

状态码：

|code|str_code|
|-|-|
|modelbox.Status.StatusCode.STATUS_SUCCESS| Success |
|modelbox.Status.StatusCode.STATUS_FAULT|Fault|
|modelbox.Status.StatusCode.STATUS_AGAIN |Try again|
|modelbox.Status.StatusCode.STATUS_NOSPACE|No space left|
|modelbox.Status.StatusCode.STATUS_ALREADY|Operation already in progress|
|modelbox.Status.StatusCode.STATUS_NOSTREAM|Out of streams resources|
|modelbox.Status.StatusCode.STATUS_BADCONF|Bad config|
|modelbox.Status.StatusCode.STATUS_NOTFOUND |Not found|
|modelbox.Status.StatusCode.STATUS_BUSY |Device or resource busy|
|modelbox.Status.StatusCode.STATUS_NOTSUPPORT |Not supported|
|modelbox.Status.StatusCode.STATUS_CONTINUE |Continue operation|
|modelbox.Status.StatusCode.STATUS_OVERFLOW |Value too large for defined data type|
|modelbox.Status.StatusCode.STATUS_EDQUOT  |Quota exceeded|
|modelbox.Status.StatusCode.STATUS_PERMIT |Operation not permitted|
|modelbox.Status.StatusCode.STATUS_EOF          |End of file|
|modelbox.Status.StatusCode.STATUS_RANGE |Out of range|
|modelbox.Status.StatusCode.STATUS_EXIST        |Already exists|
|modelbox.Status.StatusCode.STATUS_RESET |Request reset|
|modelbox.Status.StatusCode.STATUS_SHUTDOWN |Shutdown operation|
|modelbox.Status.StatusCode.STATUS_INPROGRESS   |Operation now in progress|
|modelbox.Status.StatusCode.STATUS_STOP |Stop operation|
|modelbox.Status.StatusCode.STATUS_INTERNAL     |Internal error|
|modelbox.Status.StatusCode.STATUS_INVALID      |Invalid argument|
|modelbox.Status.StatusCode.STATUS_TIMEDOUT |Operation timed out|
|modelbox.Status.StatusCode.STATUS_NOBUFS       |No buffer space available|
|modelbox.Status.StatusCode.STATUS_NODATA       |No data available|
|modelbox.Status.StatusCode.STATUS_NOMEM |Out of memory|
|modelbox.Status.StatusCode.STATUS_NOENT | No such file or directory|

## modelbox.Status.set_errormsg

设置错误信息。

**args:**  

errmsg: str 错误信息

**return:**  

无

## modelbox.Status.errormsg

获取错误信息。

**args:**  

无

**return:**  

str 当前status的errmsg

## modelbox.Status.wrap_errormsgs

获取status的所有子层次的错误信息。

**args:**  

无

**return:**  

str 当前status的子层次错误信息

## modelbox.Status.unwrap

返回wrap的status。

**args:**  

无

**return:**  

modelbox.Status wrap的status

**example:**  

```python
   import modelbox

   status = modelbox.Status(False)
   status.set_errormsg("test failed")
   print(status.errormsg())
   status1 = modelbox.Status(status, "test failed outside")
   print(status1.wrap_errormsgs())
   status2 = status1.unwrap()
   print(status == status2)

```

**result:**  

> test failed  
> Fault, test failed outside -> test failed  
> True
