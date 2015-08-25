//
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Mark.h"

@protocol CDSideBarControllerDelegate <NSObject>

- (void)cdSliderCellClicked:(NSInteger)index;
- (void)partfarmButtonClicked:(NSString*)val;
@end

@interface CDSideBarController : NSObject <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UIView              *_backgroundMenuView;
    NSMutableArray      *_buttonList;
     UIButton            *_menuButton;
    UIView*             _bgView;
    CGFloat             _viewWidth;
}


@property (nonatomic, retain) UIColor *menuColor;
@property (nonatomic) BOOL isOpen;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *nameList;


@property (nonatomic, retain) id<CDSideBarControllerDelegate> delegate;

- (CDSideBarController*)initWithImages:(NSArray*)buttonList names:(NSArray*)nameList menuButton:(UIButton*)mbutton;
- (void)insertMenuButtonOnView:(UIView*)view atPosition:(CGPoint)position;

- (void)dismissMenu;

@end

