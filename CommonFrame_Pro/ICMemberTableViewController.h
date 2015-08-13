//
//  ICMemberTableViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/5.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICGroupListViewController.h"
#import "Member.h"
#import "ICMemberInfoViewController.h"
#import "ICMemberAccessControlViewContoller.h"

typedef enum{
    MemberViewFromControllerDefault                         = 0,    //默认成员列表
    MemberViewFromControllerGroupList                       = 1,    //所有群组
    MemberViewFromControllerAuthority                       = 2,    //成员权限
    MemberViewFromControllerGroup                           = 3,    //群组成员
    MemberViewFromControllerPublishSharedAndNotification    = 4,     //发布
    MemberViewFromControllerPublishMissionResponsible       = 5,     //责任人
    MemberViewFromControllerPublishMissionParticipants      = 6,     //参与人
    MemberViewFromControllerGroupMembers                    = 7,    //群组成员
    MemberViewFromControllerCopyTo                          = 8     //抄送
}MemberViewFromControllerType;


@interface ICMemberTableViewController : UIViewController


@property (nonatomic,assign) MemberViewFromControllerType controllerType;

//Publish Mission Responsible
@property(nonatomic,strong) id icGroupListController;
@property (nonatomic,strong) NSArray* selectedResponsibleDictionary;
//Publish Mission Participants
@property (nonatomic,strong) id icPublishMisonController;
@property (nonatomic,strong) NSArray* selectedParticipantsDictionary;
//Publish Mission CopyTo
@property (nonatomic,strong) NSArray* selectedCopyToMembersArray;

@property (nonatomic,strong) NSString*    workgid;
@property (nonatomic, assign) BOOL justRead;

@end
