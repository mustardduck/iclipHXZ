//
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICWorkingDetailViewController.h"
#import "PH_UITextView.h"

@class YFInputBar;
@protocol YFInputBarDelegate <NSObject>

-(void)inputBar:(YFInputBar*)inputBar sendBtnPress:(UIButton*)sendBtn withInputString:(NSString*)str;

-(void)inputBarWithFile:(YFInputBar *)inputBar;

@end
@interface YFInputBar : UIView <UITextViewDelegate>


@property(assign,nonatomic)id<YFInputBarDelegate> delegate;

@property(strong,nonatomic)PH_UITextView *textField;
@property(strong,nonatomic)UIButton *sendBtn;
@property(strong,nonatomic) UIControl *relativeControl;
@property(strong,nonatomic) NSArray *typeList;
@property(assign,nonatomic) BOOL btnTypeHasClicked;
@property(assign,nonatomic) BOOL pishiClicked;
@property(strong,nonatomic) UIButton* btnType;

@property(strong,nonatomic) UIButton* sendCommentBtn;


//点击btn时候 清空textfield  默认NO
@property(assign,nonatomic)BOOL clearInputWhenSend;
//点击btn时候 隐藏键盘  默认NO
@property(assign,nonatomic)BOOL resignFirstResponderWhenSend;

//初始frame
@property(assign,nonatomic)CGRect originalFrame;

@property(strong,nonatomic)id parentController;
@property(assign,nonatomic)NSInteger dataCount;

//隐藏键盘
-(BOOL)resignFirstResponder;
- (void)removeType;
@end
