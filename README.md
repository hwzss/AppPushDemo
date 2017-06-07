# AppPushDemo
集成化App推送，一个分类尝试搞定。只需要映入该文件到项目中，然后通过下面代码，获取到设备的token，上传到后台服务器即可
```
    [[WZ_AppNoticeManger defaultManger] WZ_fetchPushToken:^(NSString *pushToken) {
         NSLog(@"%s",__func__);
    }];
```

由于需要给新人做的App集成推送，需求简单，就是集成一般推送然后能处理推送回调即可。
总结：![](https://github.com/hwzss/AppPushDemo/blob/master/app%E6%8E%A8%E9%80%81%E7%AE%A1%E7%90%86%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93.png)
