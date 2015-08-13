//
//  ICCreateNewGroupViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/25.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICFileViewController.h"
#import "Group.h"

typedef enum {
    ViewTypeEdit            = 1  //修改群组资料
}GroupViewType;

@interface ICCreateNewGroupViewController : UIViewController

@property(nonatomic,strong) NSArray* cAccessoryArray;
@property(nonatomic,strong) Group*   workGroup;

@property(nonatomic,assign) GroupViewType  viewType;

@property (nonatomic,strong) id     icSettingController;
@property (nonatomic,strong) id     icMainController;

@end
