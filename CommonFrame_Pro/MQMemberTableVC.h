//
//  MQMemberTableVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/29.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "UICommon.h"

@interface MQMemberTableVC : UIViewController

@property(nonatomic,strong) NSArray* ccopyToMembersArray;
@property(nonatomic,strong) Group* workGroup;

@property (nonatomic,assign) MemberViewFromControllerType controllerType;
@property (nonatomic, assign) BOOL justRead;
@property (nonatomic, assign) BOOL canDelete;
@property (nonatomic, assign) BOOL canInvite;
@property (nonatomic, assign) BOOL canSetTagAuth;
@property (nonatomic, assign) BOOL canSetAuth;

@end
