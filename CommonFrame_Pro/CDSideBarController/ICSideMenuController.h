//
//  ICSideMenuController.h
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ICMemberTableViewController.h"
#import "Member.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@protocol ICSideMenuControllerDelegate <NSObject>

- (void)icSideMenuClicked:(id)sender;
- (void)leftTopBarButtonClicked:(id)sender;

- (void)btnCreateNewGroup:(id)sender;

- (void)btnGroupMessageClicked:(id)sender;

- (void)btnGroupProjectClicked:(id)sender;

- (void)btnMyMessageClicked:(id)sender;

- (void)btnGroupDepartmentClicked:(id)sender;

- (void)tableViewCellDidClicked:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


- (void)bottomSideViewSearchTextPageOneSubmitEvent:(NSString*)searchTextFieldStr;
- (void)bottomSideViewSearchTextPageTwoSubmitEvent:(NSString*)searchTextFieldStr;
- (void)partfarmButtonClicked:(NSString*)val;

@end

@interface ICSideMenuController : NSObject


@property (nonatomic,strong)    id<ICSideMenuControllerDelegate>    delegate;
@property (nonatomic,assign)    BOOL                                isOpen;
@property (nonatomic,assign)    NSInteger                           clickedButtonTag;
@property (nonatomic,strong)    NSArray*                            indexBarSectionArray;
@property (nonatomic,strong)    NSArray*                            dataArray;


- (ICSideMenuController*)initWithImages:(NSArray*)imageList menusName:(NSArray*)nameList badgeValue:(NSArray*)badgeList onView:(UIView*)parentView searchText:(NSString*)searchString isFirstSearchBar:(BOOL)isFirstBar allNumBadge:(NSArray *)allNumBadgeList isOpen:(BOOL)isOpen;

- (void)showMenu;
- (void)btnShowAllGroup:(id)sender;
@end
