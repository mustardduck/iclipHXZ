//
//  ICMarkListViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginUser.h"
#import "ICMarkClassifyViewController.h"

typedef enum {
    ParentControllerTypePublishMission = 1          //发布任务
}ParentControllerType;

@interface ICMarkListViewController : UITableViewController

@property (nonatomic,assign) ParentControllerType   parentControllerType;
@property (nonatomic,strong) id                     parentController;
@property (nonatomic,strong) NSString*              workGroupId;
@property (nonatomic,strong) NSArray*               selectedMarkArray;
@property (nonatomic,strong) NSString*              userId;
@property (nonatomic,assign) BOOL                   isSetting;

@end
