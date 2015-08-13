//
//  ICSideTopMenuController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ICSideTopMenuControllerDelegate <NSObject>

- (void)icSideTopMenuButtonClicked:(id)sender;
- (void)partfarmButtonClicked:(NSString*)val;

@end

@interface ICSideTopMenuController : NSObject

@property (nonatomic, strong)       id<ICSideTopMenuControllerDelegate> delegate;
@property (nonatomic, assign)       BOOL    hasExec;
@property (nonatomic, assign)       BOOL    isOpen;

- (ICSideTopMenuController*)initWithMenuNameList:(NSArray*)nameList menuImageList:(NSArray*)imageList actionControl:(UIButton*)button parentView:(UIView*)pView;
- (void)showTopMenu:(id)sender;
@end
