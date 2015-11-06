//
//  MQPublishSharedAndNotifyController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/26.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQPublishSharedAndNotifyController : UIViewController

@property (nonatomic,assign) NSInteger isShared;  //1: 问题  2：建议  3：其他
//问题=异常
//建议=申请
//其他=议题

//可见范围
@property(nonatomic,strong) NSArray* ccopyToMembersArray;
//标签
@property(nonatomic,strong) NSMutableArray* cMarkAarry;
//附件
@property(nonatomic,strong) NSMutableArray* cAccessoryArray;

@property(nonatomic,strong) NSString* content;
@property(nonatomic,strong) NSString* taskId;
@property(nonatomic,strong) NSString*    workGroupId;
@property(nonatomic, strong)NSString * workGroupName;
@property(nonatomic,strong) NSString*   userId;
@property(nonatomic,strong) NSString* titleName;

@property(nonatomic,assign) BOOL isShowAllSection;//显示选择成员和标签
@property(nonatomic,assign) BOOL isRefreshMarkData;
@property(nonatomic, assign) BOOL isChangeGroup;
@property(nonatomic, assign) BOOL isEditMission;

@property(nonatomic,strong) id       icDetailViewController;
@property(nonatomic,strong) id       icGroupViewController;

@property(nonatomic,strong) NSDictionary* currentMissionDic;
@property(nonatomic,strong) NSDictionary* missionDic;

@end
