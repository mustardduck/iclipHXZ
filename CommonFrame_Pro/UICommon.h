//
//  UICommon.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/8/4.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UICommon : NSObject

#define W(obj)   (!obj?0:(obj).frame.size.width)
#define H(obj)   (!obj?0:(obj).frame.size.height)
#define X(obj)   (!obj?0:(obj).frame.origin.x)
#define Y(obj)   (!obj?0:(obj).frame.origin.y)
#define XW(obj) (X(obj)+W(obj))
#define YH(obj) (Y(obj)+H(obj))
#define heightScale 0.296
#define Font(x) [UIFont systemFontOfSize:x]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

+ (CGSize)getWidthFromLabel:(UILabel *)label;
+ (CGSize)getHeightFromLabel:(UILabel *)label;
+ (CGSize)getSizeFromString:(NSString *)str withSize:(CGSize)cSize withFont:(CGFloat)fontsize;
+ (NSString *)dayAndHourFromString:(NSString *)dateString formatStyle:(NSString *)format;

@end

@interface UIColor (Addition)

+ (UIColor *) disableGreyColor;//灰字不能点击
+ (UIColor *) greyStatusBarColor;

@end