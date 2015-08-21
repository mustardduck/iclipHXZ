//
//  ICPublishMissionViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/23.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICGroupListViewController.h"
#import "ICMarkListViewController.h"
#import <ZYQAssetPickerController.h>
#import "Mark.h"
#import "Mission.h"
#import "ICFileViewController.h"


@interface ICPublishMissionViewController : UIViewController <ZYQAssetPickerControllerDelegate,UITextViewDelegate, UITextFieldDelegate>

//责任人
@property(nonatomic,strong) NSArray* responsibleDic;
//参与人
@property(nonatomic,strong) NSArray* participantsIndexPathArray;
//抄送
@property(nonatomic,strong) NSArray* ccopyToMembersArray;
//标签
@property(nonatomic,strong) NSArray* cMarkAarry;
//附件
@property(nonatomic,strong) NSArray* cAccessoryArray;
//完成时间
@property(nonatomic,strong) NSString* strFinishTime;
//提醒时间
@property(nonatomic,strong) NSString* strRemindTime;

@property(nonatomic,strong) NSString* content;
@property(nonatomic,strong) NSString* taskId;
@property(nonatomic,strong) NSString* workGroupId;
@property(nonatomic,strong) NSString* userId;
@property(nonatomic,strong) NSString* titleName;

@property(nonatomic,strong) id       icDetailViewController;
@property(nonatomic,strong) id       icGroupViewController;
@end
