//
//  MQSearchMenuController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/23.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Mark.h"
#import "SKSTableView.h"

@protocol MQSearchMenuControllerDelegate <NSObject>

- (void)MQSearchMenuButtonClicked:(NSDictionary *)searchDic;
- (void)partfarmButtonClicked:(NSString*)val;

@end

@interface MQSearchMenuController : NSObject<UIGestureRecognizerDelegate,UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIView              *_backgroundMenuView;
    NSMutableArray      *_buttonList;
    UIButton            *_menuButton;
    UIView*             _bgView;
    CGFloat             _viewWidth;
}

@property (nonatomic, retain) UIColor *menuColor;
@property (nonatomic, assign)       BOOL    isOpen;
@property (nonatomic, strong) UICollectionView *mainCollView;
//@property (nonatomic, strong) SKSTableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *nameList;
@property (nonatomic, strong)       id<MQSearchMenuControllerDelegate> delegate;


- (MQSearchMenuController*)initWithImages:(NSArray*)images  names:(NSArray*)nameList  menuButton:(UIButton*)button;

- (void)insertMenuButtonOnView:(UIView*)view atPosition:(CGPoint)position;
- (void)dismissMenu;


@end
