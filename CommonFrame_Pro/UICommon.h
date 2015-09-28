//
//  UICommon.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/8/4.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ORIGINAL_MAX_WIDTH 640.0f

typedef void (^keyboardBlock) ();

@interface UICommon : NSObject

#define W(obj)   (!obj?0:(obj).frame.size.width)
#define H(obj)   (!obj?0:(obj).frame.size.height)
#define X(obj)   (!obj?0:(obj).frame.origin.x)
#define Y(obj)   (!obj?0:(obj).frame.origin.y)
#define XW(obj) (X(obj)+W(obj))
#define YH(obj) (Y(obj)+H(obj))
#define heightScale 0.296
#define Font(x) [UIFont systemFontOfSize:x]
#define BFont(x) [UIFont boldSystemFontOfSize:x]


#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define SCREENWIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREENHEIGHT ([UIScreen mainScreen].bounds.size.height)

+ (CGSize)getWidthFromLabel:(UILabel *)label;
+ (CGSize)getHeightFromLabel:(UILabel *)label;
+ (CGSize)getSizeFromString:(NSString *)str withSize:(CGSize)cSize withFont:(UIFont*)font;
+ (NSString *)dayAndHourFromString:(NSString *)dateString formatStyle:(NSString *)format;
+ (NSString*) formatTime:(NSString*)input withLength:(int)length;
+ (float)getSystemVersion;

+ (UIViewController *)getOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController;
+ (void)popOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController;

+ (void) showImagePicker:(id)delegate view:(UIViewController*)controller;
+ (void) showCamera:(id)delegate view:(UIViewController*) controller allowsEditing:(BOOL)allow;

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

@end

@interface UIViewController (expanded)
//KeyboardUI
- (void)addDoneToKeyboard:(UIView *)activeView;//对键盘添加“完成”按钮
- (void)hiddenKeyboard;

@end

@interface UIColor (Addition)

+ (UIColor *) disableGreyColor;//灰字不能点击
+ (UIColor *) greyStatusBarColor;//状态栏背景颜色
+ (UIColor *) cellHoverBackgroundColor;//列表点击时背景颜色；

@end

