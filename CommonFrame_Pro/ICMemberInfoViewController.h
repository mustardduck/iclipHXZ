//
//  ICMemberInfoViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh.h>
#import "Member.h"
#import "Mission.h"
#import "ICPersonalInfoViewController.h"
#import "LoginUser.h"

@interface ICMemberInfoViewController : UIViewController

@property (nonatomic,strong) Member* memberObj;

@property (nonatomic, strong) NSMutableArray * dataListArr;

@property (nonatomic, strong) id icMainVC;

@end
