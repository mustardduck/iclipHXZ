//
//  ICFileViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/13.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpBaseFile.h"
#import "CommonFile.h"
#import "Accessory.h"
#import "UICommon.h"

@class ICFileViewController;

@interface ICFileViewController : UIViewController


@property(nonatomic,strong) NSMutableArray*    uploadFileArray;
@property(nonatomic,strong) NSMutableArray*    hasUploadedFileArray;
@property(nonatomic,strong) NSMutableArray*    AccessoryArray;

@property(nonatomic,strong) id          icPublishMissionController;

@property(nonatomic,strong) NSString*    workGroupId;

@end
