//
//  MQworkTimeSelectVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/7.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkPlanTime.h"

@protocol MQworkTimeSelectDelegate <NSObject>

- (void)didSelectTime:(WorkPlanTime*)time;
- (void)partfarmButtonClicked:(NSString*)val;

@end

@interface MQworkTimeSelectVC : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL    isOpen;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong)       id<MQworkTimeSelectDelegate> delegate;

- (MQworkTimeSelectVC*)initWithMenuNameList:(NSArray*)timeList actionControl:(UIButton*)button parentView:(UIView*)pView;

- (void)showTopMenu:(id)sender;

@end
