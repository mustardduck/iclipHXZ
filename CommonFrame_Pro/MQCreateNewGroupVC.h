//
//  MQCreateNewGroupVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/29.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Group.h"

typedef enum {
    MQViewTypeEdit            = 1  //修改群组资料
}MQGroupViewType;

@interface MQCreateNewGroupVC : UIViewController

@property(nonatomic,strong) Group*   workGroup;
@property(nonatomic,assign) MQGroupViewType  viewType;
@property (nonatomic,strong) id     icSettingController;

@end
