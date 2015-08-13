//
//  ICSettingGroupViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/25.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMemberTableViewController.h"
#import "ICMemberInvitationTableViewController.h"
#import "ICCreateNewGroupViewController.h"
#import "ICCreateMarkViewController.h"
#import "ICMarkListViewController.h"
#import "ICMarkManagementViewController.h"

@interface ICSettingGroupViewController : UITableViewController

@property(nonatomic,strong) NSString* workGroupId;
@property(nonatomic,strong) Group* workGroup;

@property(nonatomic,strong) id  icGroupDetailController;

@end
