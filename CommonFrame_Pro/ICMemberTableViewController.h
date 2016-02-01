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
#import "UICommon.h"


@interface ICMemberTableViewController : UIViewController


@property (nonatomic,assign) MemberViewFromControllerType controllerType;

//Publish Mission Responsible
@property(nonatomic,strong) id icGroupListController;
@property (nonatomic,strong) NSArray* selectedResponsibleDictionary;
//Publish Mission Participants
@property (nonatomic,strong) id icPublishMisonController;
@property (nonatomic,strong) id icCreateGroupSecondController;

@property (nonatomic,strong) NSArray* selectedParticipantsDictionary;
//Publish Mission CopyTo
@property (nonatomic,strong) NSArray* selectedCopyToMembersArray;

@property (nonatomic,strong) NSString*    workgid;
@property (nonatomic, assign) BOOL justRead;
@property (nonatomic, assign) BOOL isCC;
@property (nonatomic, assign) BOOL isKJFW;
@property (nonatomic, assign) BOOL isFromCreatGroupInvite;

@property (nonatomic,strong) NSArray* invitedArray;

@end
