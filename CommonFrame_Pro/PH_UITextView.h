//
//  PH_UITextView.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/8/20.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PH_UITextView : UITextView {
    
    NSString *placeholder;
    
    UIColor *placeholderColor;
    
    
    
@private
    
    UILabel *placeHolderLabel;
    
}



@property(nonatomic, retain) UILabel *placeHolderLabel;

@property(nonatomic, retain) NSString *placeholder;

@property(nonatomic, retain) UIColor *placeholderColor;



-(void)textChanged:(NSNotification*)notification;



@end
