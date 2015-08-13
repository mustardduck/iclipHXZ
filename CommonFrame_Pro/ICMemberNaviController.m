//
//  ICMemberNaviController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/3.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberNaviController.h"

@implementation ICMemberNaviController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof (self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
