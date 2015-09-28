//
//  RRPageControl.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/9/28.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRPageControl : UIPageControl{
    UIImage *imagePageStateNormal;
    UIImage *imagePageStateHighlighted;
}

- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, retain) UIImage *imagePageStateNormal;
@property (nonatomic, retain) UIImage *imagePageStateHighlighted;

@end
