//
//  RRAttributedString.h
//  miaozhuan
//
//  Created by 孙向前 on 14-11-5.
//  Copyright (c) 2014年 zdit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RRAttributedString : NSObject
/**
 * @prama text 字符串
 * @prama textColor 改变区域的颜色
 * @prama range 改变的区域
 */
+ (NSAttributedString *)setText:(NSString *)text
                          color:(UIColor *)textColor
                          range:(NSRange)range;
/**
 * @prama text 字符串
 * @prama font 改变区域的font
 * @prama range 改变的区域
 */
+ (NSAttributedString *)setText:(NSString *)text
                          font:(UIFont *)font
                          range:(NSRange)range;
/**
 * @prama text 字符串
 * @prama textColor 改变区域的颜色
 * @prama font 改变区域的font
 * @prama range 改变的区域
 */
+ (NSAttributedString *)setText:(NSString *)text
                           font:(UIFont *)font
                          color:(UIColor *)textColor
                          range:(NSRange)range;

/**
 * @prama text 字符串中间横线
 * @prama textColor 改变区域的颜色
 * @prama font 改变区域的font
 * @prama range 改变的区域
 */
+ (NSAttributedString *)setStrikeThroughText:(NSString *)text
                           font:(UIFont *)font
                          color:(UIColor *)textColor
                          range:(NSRange)range;

@end
