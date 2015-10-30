//
//  MQPublishMissionController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/13.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQPublishMissionController : UIViewController

//责任人
@property(nonatomic,strong) NSArray* responsibleDic;
//参与人
@property(nonatomic,strong) NSArray* participantsIndexPathArray;
//抄送
@property(nonatomic,strong) NSArray* ccopyToMembersArray;
//标签
@property(nonatomic,strong) NSMutableArray* cMarkAarry;
//附件
@property(nonatomic,strong) NSMutableArray* cAccessoryArray;
//完成时间
@property(nonatomic,strong) NSString* strFinishTime;
//提醒时间
@property(nonatomic,strong) NSString* strRemindTime;

@property(nonatomic,strong) NSString* content;
@property(nonatomic,strong) NSString* taskId;
@property(nonatomic,strong) NSString* workGroupId;
@property(nonatomic, strong)NSString * workGroupName;
@property(nonatomic,strong) NSString* userId;
@property(nonatomic,strong) NSString* titleName;

@property(nonatomic,assign) BOOL isShowAllSection;//显示选择成员和标签
@property(nonatomic,assign) BOOL isRefreshMarkData;
@property(nonatomic, assign) BOOL isMainMission;
@property(nonatomic, assign) BOOL isChangeGroup;
@property(nonatomic,assign) NSInteger currentEditChildIndex;


@property(nonatomic,strong) id       icDetailViewController;
@property(nonatomic,strong) id       icGroupViewController;
@property(nonatomic,strong) id       icMissionMainViewController;

@property(nonatomic,strong) NSMutableArray* savedChildMissionArr;
@property(nonatomic,strong) NSDictionary* currentMissionDic;
@property(nonatomic,strong) NSDictionary* missionDic;

@end
