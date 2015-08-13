//
//  ICMarkManagementViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginUser.h"
#import "Mark.h"

@interface ICMarkManagementViewController : UIViewController

@property (nonatomic,strong) NSString*              workGroupId;
@property (nonatomic, assign) BOOL justRead;//只看，不能编辑

@end
