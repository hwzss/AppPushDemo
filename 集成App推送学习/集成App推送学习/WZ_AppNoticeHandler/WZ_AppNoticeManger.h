//
//  WZ_AppNoticeManger.h
//  集成App推送学习
//
//  Created by qwkj on 2017/5/26.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    noticeTaped,
    noticeUnTaped,
    noticeTapUnkown,
} WZ_AppNoticeTapType;

typedef void(^WZ_fetchPushTokenBlock)(NSString *pushToken);

@interface WZ_AppNoticeManger : NSObject

+(instancetype)defaultManger;

-(void)WZ_registerForRemoteNotifications;

-(void)WZ_fetchPushToken:(WZ_fetchPushTokenBlock )fetchBlock;
@end
