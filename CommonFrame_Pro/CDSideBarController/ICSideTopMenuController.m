//
//  ICSideTopMenuController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICSideTopMenuController.h"

@interface ICSideTopMenuController()
{
    UIView* _mainView;

}

@end

@implementation ICSideTopMenuController

- (ICSideTopMenuController*)initWithMenuNameList:(NSArray*)nameList menuImageList:(NSArray*)imageList actionControl:(UIButton*)button parentView:(UIView*)pView
{
    _mainView = pView;
    
    [_mainView setBackgroundColor:[UIColor blackColor]];

    [button addTarget:self action:@selector(showTopMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //CGFloat height = pView.bounds.size.height;
    
    int index = 0;
    NSInteger columeCount = nameList.count;
    CGFloat menuWidth = (width - 20 - 30) / 4;
    CGFloat menuHeight = 80;
    
    for (int j = 0; j < columeCount; j++)
    {
        index = j;
        
        UIView* menuView = [[UIView alloc]
                            initWithFrame:CGRectMake((menuWidth * j) + (j+1)*10, 5, menuWidth, menuHeight)];
        
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake((menuWidth - 24) / 2, 10, 24, 24)];
        [image setImage:[imageList objectAtIndex:index]];
        
        UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,menuWidth,menuHeight)];
        
        //[menuButton setImage:[imageList objectAtIndex:index] forState:UIControlStateNormal];
        [menuButton setBackgroundColor:[UIColor clearColor]];
        [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setTag:index];
        
        
        UILabel* menuName = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, menuWidth, 15)];
        
        [menuName setText:[nameList objectAtIndex:index]];
        [menuName setBackgroundColor:[UIColor clearColor]];
        [menuName setTextAlignment:NSTextAlignmentCenter];
        [menuName setTextColor:[UIColor whiteColor]];
        [menuName setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        
        [menuButton addSubview:image];
        [menuButton addSubview:menuName];
        
        [menuView addSubview:menuButton];
        //[menuView addSubview:menuName];
        
        [_mainView addSubview:menuView];
        
    }
    
    UIButton* mbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, width, 18)];
    mbutton.backgroundColor = [UIColor clearColor];
    mbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [mbutton addTarget:self action:@selector(showTopMenu:) forControlEvents:UIControlEventTouchUpInside];
    [mbutton setImage:[UIImage imageNamed:@"btn_caidan"] forState:UIControlStateNormal];
    
    [_mainView addSubview:mbutton];

    pView = _mainView;
    
    [self performDismissAnimation];
    
    return self;
}

- (void)showTopMenu:(id)sender
{
    if ([sender isKindOfClass:[NSString class]]) {
        
        if (_isOpen) {
            [self performDismissAnimation];
            _isOpen = FALSE;
        }
        else{
            [self performOpenAnimation];
            _isOpen = TRUE;
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(partfarmButtonClicked:)]) {
            [self.delegate partfarmButtonClicked:@"1"];
        }
    }
    
    
    
}

- (IBAction)menuButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(icSideTopMenuButtonClicked:)]) {
        [self.delegate icSideTopMenuButtonClicked:sender];
    }
    
    [self showTopMenu:sender];
}

#pragma mark -
#pragma mark - Animations

- (void)performDismissAnimation
{
    [UIView animateWithDuration:0.4 animations:^{
        _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -100);
    }];
}

- (void)performOpenAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        }];
    });
}

@end
