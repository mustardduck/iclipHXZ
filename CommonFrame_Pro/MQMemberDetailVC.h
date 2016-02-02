//
//  MQMemberDetailVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/1.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"
#import "Group.h"

@interface MQMemberDetailVC : UIViewController

@property (nonatomic, strong) Member * member;
@property(nonatomic,strong) Group* workGroup;
@property (nonatomic, assign) BOOL canSetTagAuth;
@property (nonatomic, assign) BOOL canSetAuth;
@end
