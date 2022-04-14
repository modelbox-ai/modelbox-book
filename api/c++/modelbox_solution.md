# modelbox.Solution

|函数|作用|
|-|-|
|[构造方法](#构造方法)|创建solution|
|[SetSolutionDir](#setsolutiondir)|设置solution的路径|
|[SetArgs](#setargs)|设置solution的参数|
|[GetSolutionDir](#getsolutiondir)|获取solution的路径|
|[GetSolutionName](#getsolutionname)|获取solution的名字|
---

## 构造方法

创建solution

```c++
    Solution(const std::string &solution_name);
```

**args:**  

* **solution_name** (string) ——  solution对象的名字

**return:**  

modelbox::Solution  Solution对象

## SetSolutionDir

设置solution的路径

```c++
    void SetSolutionDir(const std::string &dir);
```

**args:**  

* **dir** (string) ——  设置solution对象的路径

**return:**  

无

## SetArgs

设置solution的参数

```c++
    Solution &SetArgs(const std::string &key, const std::string &value);
```

**args:**  

* **key** (string) ——  设置solution参数的key值
* **value** (string) ——  设置solution参数的value值

**return:**  

modelbox::Solution

## GetSolutionDir

获取solution对象的路径

```c++
    const std::string GetSolutionDir() const;
```

**args:**  

无

**return:**  

string solution对象的路径

## GetSolutionName

获取solution对象的名字

```c++
    const std::string GetSolutionName() const;
```

**args:**  

无

**return:**  

string solution对象的名字

**example:**  

```c++
    #include <modelbox/flow.h>

    int main() {
        string path = "test/solution/path";
        strint name = "test_solution";
        Solution solution(name);

        solution.SetSolutionDir(path);
        auto get_name = solution.GetSolutionName();
        auto get_path = solution.GetSolutionDir();

        solution.SetArgs("key1", "value1").SetArgs("key2", "value2");
        MBLOG_INFO << get_name << ", " << get_path;

        return 0;
    }

```

**result:**

> test_solution, test/solution/path
