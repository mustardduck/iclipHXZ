//
//  MQworkGroupSelectVC.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/6.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@protocol MQworkGroupSelectDelegate <NSObject>

- (void)didSelectGroup:(Group*)group;
- (void)partfarmButtonClicked:(NSString*)val;

@end

@interface MQworkGroupSelectVC : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL    isOpen;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, strong)       id<MQworkGroupSelectDelegate> delegate;

- (MQworkGroupSelectVC*)initWithMenuNameList:(NSArray*)groupList actionControl:(UIButton*)button parentView:(UIView*)pView;

- (void)showTopMenu:(id)sender;

@end
