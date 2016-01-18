//
//  WorkPlanAddMissionController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/29.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkPlanAddMissionController : UIViewController

@property (nonatomic, strong) NSString * workGroupId;
@property (nonatomic, strong) NSString * workGroupName;
@property (nonatomic, strong) NSString * labelIdStr;
@property (nonatomic, strong) NSString * headerTitle;
@property (nonatomic, strong) id MQPlanEditVC;
@property (nonatomic, strong) NSMutableArray * selectedRows;//所有标签已选择的任务数组
@property (nonatomic, assign) NSInteger selectedIndex;//某个标签在所有数组中的index
@property (nonatomic, strong) NSMutableArray * selectedIndexList;//某个标签下已选择的任务数组
@property (nonatomic, assign) BOOL isEdit;

@end
