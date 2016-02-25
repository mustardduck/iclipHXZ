//
//  WorkPlanEditMainController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/23.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "ICMainViewController.h"

@interface WorkPlanEditMainController : UIViewController

@property (nonatomic, strong) NSString * workGroupId;
@property (nonatomic, strong) NSString * workGroupName;
@property (nonatomic, strong) NSArray * rows;
@property (nonatomic, strong) NSString * taskId;
@property (nonatomic, strong) NSString * startTime;
@property (nonatomic, strong) NSString * finishTime;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) Group * currentGroup;
@property(nonatomic,strong) id       icDetailViewController;
@property (nonatomic, strong) id icMainVC;

@property (nonatomic, strong) NSMutableArray * selectedRows;//所有标签已选择的任务数组
@property (nonatomic, assign) NSInteger selectedIndex;//某个标签在所有数组中的index
@property (nonatomic, strong) NSMutableArray * selectedIndexList;//某个标签下已选择的任务数组

@end

