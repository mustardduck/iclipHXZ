//
//  WorkPlanEditController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/29.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "ICMainViewController.h"

@interface WorkPlanEditController : UIViewController

@property (nonatomic, strong) NSString * workGroupId;
@property (nonatomic, strong) NSString * workGroupName;
@property (nonatomic, strong) NSMutableArray * rows;
@property (nonatomic, strong) NSString * taskId;
@property (nonatomic, strong) NSString * startTime;
@property (nonatomic, strong) NSString * finishTime;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) Group * currentGroup;
@property(nonatomic,strong) id       icDetailViewController;
@property (nonatomic, strong) id icMainVC;
@end
