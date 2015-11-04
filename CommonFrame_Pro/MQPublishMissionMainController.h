//
//  MQPublishMissionMainController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/27.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQPublishMissionMainController : UIViewController

@property(nonatomic,strong) NSString* workGroupId;
@property(nonatomic, strong)NSString * workGroupName;
@property(nonatomic, strong)NSMutableDictionary * mainMissionDic;
@property(nonatomic, strong)NSMutableArray * childMissionArr;
@property(nonatomic, assign)BOOL isEdit;
@property (nonatomic, strong) NSString * taskId;

@property(nonatomic,strong) id       icDetailViewController;

@end
