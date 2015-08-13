//
//  ICMemberInvitationTableViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginUser.h"
#import "Group.h"
#import "ICCreateMarkViewController.h"
#import "ICMemberTableViewController.h"
#import "Member.h"

@interface ICMemberInvitationTableViewController : UITableViewController

@property(nonatomic,strong) NSString* workGroupId;


@property(nonatomic,strong) NSArray* ccopyToMembersArray;

@end
