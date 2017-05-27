//
//  WZ_AppNoticeManger.m
//  集成App推送学习
//
//  Created by qwkj on 2017/5/26.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import "WZ_AppNoticeManger.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>

#define WZ_IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define WZ_IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define WZ_IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define WZ_IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface WZ_AppNoticeManger ()<UNUserNotificationCenterDelegate>

@property(weak,nonatomic)UIApplication *application;

@property(copy,nonatomic)NSString *devicePushToken;

@property(copy,nonatomic)WZ_fetchPushTokenBlock fetchPushTokenblock;
@end

@implementation WZ_AppNoticeManger

static id _instance;
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    _instance=[super allocWithZone:zone];
    return _instance;
}
+(instancetype)defaultManger{
    if(!_instance){
        _instance=[[[self class] alloc]init];
    }
    return _instance;
}
-(UIApplication *)application{
    if (!_application) {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}
-(void)setDevicePushToken:(NSString *)devicePushToken{
    _devicePushToken = devicePushToken;
    if (_fetchPushTokenblock) {
        _fetchPushTokenblock(devicePushToken);
        _fetchPushTokenblock = nil;
    }
}
-(void)WZ_fetchPushToken:(WZ_fetchPushTokenBlock )fetchBlock{
    if (self.devicePushToken) {
        if (fetchBlock) {
            fetchBlock(self.devicePushToken);
        }
    }else{
        self.fetchPushTokenblock = fetchBlock;
    }
}
#pragma -mark 注册远程通知
-(void)WZ_registerForRemoteNotifications{
    if (WZ_IOS10_OR_LATER) {
        UNUserNotificationCenter *center  = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self.application registerForRemoteNotifications];
            }else{
                
            }
        }];
    }else if (WZ_IOS8_OR_LATER){
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil];
        [self.application registerUserNotificationSettings:setting];
    }else{
        [self.application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    }
    
}

-(void)handlerNotificationWithNUserInfo:(NSDictionary *)userInfo IsTap:(WZ_AppNoticeTapType )tapType{
    
}

#pragma -mark UNUserNotificationCenterDelegate
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    [self handlerNotificationWithNUserInfo:response.notification.request.content.userInfo IsTap:noticeTaped];
    
    completionHandler();
}

@end

@interface AppDelegate (WZ_handlerNotice)<UIApplicationDelegate>

@end



BOOL classSwizzleInstanceMethod(Class aClass, SEL originalSel,SEL swizzleSel){
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSel);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSel);
    
    BOOL didAddMethod = class_addMethod(aClass, originalSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass, swizzleSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        method_setImplementation(swizzleMethod, imp_implementationWithBlock(<#id block#>))
    }else{
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    
    return YES;
}

@implementation AppDelegate (WZ_handlerNotice)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [self class];
        
        //hook launching to configure
        classSwizzleInstanceMethod(aClass, @selector(application:didFinishLaunchingWithOptions:), @selector(WZ_application:didFinishLaunchingWithOptions:));
        //hook register
        classSwizzleInstanceMethod(aClass, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), @selector(WZ_application:didRegisterForRemoteNotificationsWithDeviceToken:));
        classSwizzleInstanceMethod(aClass, @selector(application:didFailToRegisterForRemoteNotificationsWithError:), @selector(WZ_application:didFailToRegisterForRemoteNotificationsWithError:));
        
        if (!WZ_IOS10_OR_LATER) {
            classSwizzleInstanceMethod(aClass, @selector(application:didReceiveRemoteNotification:), @selector(WZ_application:didReceiveRemoteNotification:));
            classSwizzleInstanceMethod(aClass, @selector(WZ_application:didReceiveLocalNotification:), @selector(WZ_application:didReceiveLocalNotification:));
        }
    });
}
#pragma -mark recive notice  and configure AppNoticehandler
-(BOOL)WZ_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //configure register
    [[WZ_AppNoticeManger defaultManger] WZ_registerForRemoteNotifications];
    
    if (!WZ_IOS10_OR_LATER) {
        //iOS上，可以在didReceiveNotificationResponse接收到点击返回
        NSDictionary *remoteUserInfo =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *LocalUserInfo =[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (remoteUserInfo||LocalUserInfo) {
            [[WZ_AppNoticeManger defaultManger] handlerNotificationWithNUserInfo:remoteUserInfo?remoteUserInfo:LocalUserInfo IsTap:noticeTaped];
        }
    }

    return [self WZ_application:application didFinishLaunchingWithOptions:launchOptions];
    
}

#pragma -mark register Token
-(void)WZ_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *deviceTokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    [WZ_AppNoticeManger defaultManger].devicePushToken = deviceTokenStr;
    
    [self WZ_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
-(void)WZ_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    [self WZ_application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
#pragma -mark recevice and handle notification
-(void)WZ_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    [[WZ_AppNoticeManger defaultManger] handlerNotificationWithNUserInfo:userInfo IsTap:noticeTapUnkown];
    
    [self WZ_application:application didReceiveRemoteNotification:userInfo];
}
-(void)WZ_application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    [[WZ_AppNoticeManger defaultManger] handlerNotificationWithNUserInfo:notification.userInfo IsTap:noticeTapUnkown];
    
    [self WZ_application:application didReceiveLocalNotification:notification];
}



@end
