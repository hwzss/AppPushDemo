//
//  ViewController.m
//  集成App推送学习
//
//  Created by qwkj on 2017/5/26.
//  Copyright © 2017年 qwkj. All rights reserved.
//

#import "ViewController.h"
#import "WZ_AppNoticeManger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[WZ_AppNoticeManger defaultManger] WZ_fetchPushToken:^(NSString *pushToken) {
         NSLog(@"%s",__func__);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
