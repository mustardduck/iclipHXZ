//
//  ICMainViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/2.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlideNavigationController.h>
#import "CDSideBarController.h"
#import "ICSideMenuController.h"
#import "ICSideTopMenuController.h"
#import "ICPublishSharedAndNotifyViewController.h"
#import "ICMemberTableViewController.h"
#import "UIColor+HexString.h"
#import "Mission.h"
#import "Group.h"
#import "Member.h"
#import "ICWorkingDetailViewController.h"
#import "ICCreateNewGroupViewController.h"

@interface ICMainViewController : UIViewController<CDSideBarControllerDelegate,ICSideMenuControllerDelegate,UINavigationControllerDelegate,ICSideTopMenuControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSString*  loginUserID;

@property (nonatomic,strong) NSString*  strIndexForDetail;

@property (nonatomic,strong) NSString*  pubGroupId;

@property(nonatomic,strong) NSString*   hasCreatedNewGroup; //yes:1 NO:0

@property(nonatomic,strong) NSString * isRefreshBottom;


@end
