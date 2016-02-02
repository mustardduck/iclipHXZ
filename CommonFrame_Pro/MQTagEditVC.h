//
//  MQTagEditVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/2.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface MQTagEditVC : UITableViewController

@property (nonatomic, strong) Group * workGroup;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) BOOL canCreate;

@end
