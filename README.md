# AppPushDemo
集成化App推送，一个分类尝试搞定。只需要映入该文件到项目中，然后通过下面代码，获取到设备的token，上传到后台服务器即可
```
    [[WZ_AppNoticeManger defaultManger] WZ_fetchPushToken:^(NSString *pushToken) {
         NSLog(@"%s",__func__);
    }];
```

由于需要给新人做的App集成推送，需求简单，就是集成一般推送然后能处理推送回调即可。
总结：
