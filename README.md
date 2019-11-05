#Html5iOS

该项目是4-5年前swift开始流行时做的项目，可供大家学习参考。
封装实现了JS与native交互，相当于在HTML5项目中加一个外壳。
实现的功能有打开原生窗口NKWebview、iOS本地通知、关闭窗口等等，可以继续扩展

比如：

```
//JS打开窗体
XwebBridge.call('open',{url:'http://www.codeoo.cn'});

//JS本地通知
XwebBridge.call('notify',{body:'message'});

//JS关闭窗体
XwebBridge.call('close');

```


###Friends who like it, please take the experiment
