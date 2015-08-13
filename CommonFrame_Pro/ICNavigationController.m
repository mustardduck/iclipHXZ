//
//  ICNavigationController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/1.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICNavigationController.h"
#import "UIColor+HexString.h"

@implementation ICNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof (self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
    
    [self.navigationBar setBackgroundColor:[UIColor colorWithHexString:@"#201f24"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.icLoginViewController != nil) {
        for (UIControl* control in self.icLoginViewController.view.subviews) {
            if (control.tag == 201) {
                [control removeFromSuperview];
                break;
            }
        }
    }
}

@end
