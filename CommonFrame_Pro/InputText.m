//
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import "InputText.h"





@implementation InputText


- (InputText *)initWithIcon:(NSString *)icon point:(NSString *)point textFieldControl:(UITextField*)textField showBottomLine:(BOOL)isShow
{
    self = [self init];
    if (self) {
        [self setupWithIcon:icon point:point textFieldControl:textField showBottomLine:isShow];
    }
    return self;
}

- (UITextField*)setupWithIcon:(NSString *)icon point:(NSString *)point  textFieldControl:(UITextField*)textField  showBottomLine:(BOOL)isShow
{
    CGRect frame = textField.frame;
    
    //textField = [[UITextField alloc] initWithFrame:frame];
    
    if (isShow) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        view.alpha = 0.5;
        view.backgroundColor = [UIColor grayColor];
        [textField addSubview:view];
    }
    
    textField.placeholder = point;
    textField.font = [UIFont systemFontOfSize:16];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    UIImage *bigIcon = [UIImage imageNamed:icon];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:bigIcon];
    if (icon != nil) {
        [iconView setFrame:CGRectMake(0, 0, 20, 20)];
    }
    iconView.contentMode = UIViewContentModeLeft;
    textField.leftView = iconView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [textField setBorderStyle:UITextBorderStyleNone];
    
    [textField setBackgroundColor:[UIColor clearColor]];
    
    return textField;
}


@end

