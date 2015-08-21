//
//  ICPublishSharedAndNotifyViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/23.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMemberTableViewController.h"
#import "UICommon.h"

@interface ICPublishSharedAndNotifyViewController : UIViewController

@property (nonatomic,assign) NSInteger isShared;  //1: 问题  2：建议  3：通知
//可见范围
@property(nonatomic,strong) NSArray* ccopyToMembersArray;
//标签
@property(nonatomic,strong) NSArray* cMarkAarry;
//附件
@property(nonatomic,strong) NSArray* cAccessoryArray;

@property(nonatomic,strong) NSString* content;
@property(nonatomic,strong) NSString* taskId;
@property(nonatomic,strong) NSString*    workGroupId;
@property(nonatomic,strong) NSString*   userId;
@property(nonatomic,strong) NSString* titleName;


@property(nonatomic,strong) id       icDetailViewController;
@property(nonatomic,strong) id       icGroupViewController;

@end
