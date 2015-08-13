//
//  ICCreateMarkViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexString.h"
#import "Group.h"
#import "LoginUser.h"
#import "Mark.h"

typedef enum {
    ViewTypeMark            = 0, //新建标签
    ViewTypeEmail           = 1  //添加邮箱
}ViewType;

@interface ICCreateMarkViewController : UIViewController

@property(nonatomic,assign) ViewType viewType;
@property(nonatomic,strong) NSString* workGroupId;

@end
