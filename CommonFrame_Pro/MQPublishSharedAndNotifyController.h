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
//可见范围
@property(nonatomic,strong) NSArray* ccopyToMembersArray;
//标签
@property(nonatomic,strong) NSArray* cMarkAarry;
//附件
@property(nonatomic,strong) NSArray* cAccessoryArray;

@property(nonatomic,strong) NSString* content;
@property(nonatomic,strong) NSString* taskId;
@property(nonatomic,strong) NSString*    workGroupId;
@property(nonatomic, strong)NSString * workGroupName;
@property(nonatomic,strong) NSString*   userId;
@property(nonatomic,strong) NSString* titleName;

@property(nonatomic,assign) BOOL isShowAllSection;
@property(nonatomic,assign) BOOL isRefreshMarkData;

@property(nonatomic,strong) id       icDetailViewController;
@property(nonatomic,strong) id       icGroupViewController;

@end
