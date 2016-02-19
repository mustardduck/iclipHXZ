//
//  MQPersonalInfoFieldEditVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/18.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginUser.h"
#import "MQPersonalInfoFieldEditVC.h"

@interface MQPersonalInfoFieldEditVC : UIViewController

@property (nonatomic, assign) NSInteger type;//1 名字 2 手机 3邮箱
@property (nonatomic, strong) LoginUser * user;
@property (nonatomic, strong) id MQPerInfoVC;

@end
