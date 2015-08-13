//
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol InputTextDelegate <NSObject>

@end

@interface InputText : NSObject <UITextFieldDelegate>
{
    
}

- (InputText *)initWithIcon:(NSString *)icon point:(NSString *)point  textFieldControl:(UITextField*)textField  showBottomLine:(BOOL)isShow;
- (UITextField*)setupWithIcon:(NSString *)icon point:(NSString *)point  textFieldControl:(UITextField*)textField  showBottomLine:(BOOL)isShow;

@property (nonatomic,retain) id<InputTextDelegate> delegate;


@end

