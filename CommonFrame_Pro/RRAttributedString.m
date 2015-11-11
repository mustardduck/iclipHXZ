//
//  RRAttributedString.m
//  miaozhuan
//
//  Created by 孙向前 on 14-11-5.
//  Copyright (c) 2014年 zdit. All rights reserved.
//

#import "RRAttributedString.h"

static RRAttributedString *attributeString = nil;

@implementation RRAttributedString

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!attributeString) {
            attributeString = [[RRAttributedString alloc] init];
        }
    });
    return attributeString;
}

+ (NSAttributedString *)setText:(NSString *)text
                          color:(UIColor *)textColor
                          range:(NSRange)range {
    return [[self shareInstance] setText:text color:textColor font:nil range:range];
}

+ (NSAttributedString *)setText:(NSString *)text
                           font:(UIFont *)font
                          range:(NSRange)range {
    return [[self shareInstance] setText:text color:nil font:font range:range];
}

+ (NSAttributedString *)setText:(NSString *)text
                           font:(UIFont *)font
                          color:(UIColor *)textColor
                          range:(NSRange)range {
    return [[self shareInstance] setText:text color:textColor font:font range:range];
}

- (NSAttributedString *)setText:(NSString *)text
                        color:(UIColor *)textColor
                         font:(UIFont *)font
                        range:(NSRange)range {
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:text];
    
    NSMutableDictionary *attDic = [[NSMutableDictionary alloc] init];
    
    if (font) {
        [attDic setValue:font forKey:NSFontAttributeName];
    }
    if (textColor) {
        [attDic setValue:textColor forKey:NSForegroundColorAttributeName];
    }
    [attributeString setAttributes:attDic range:range];
    return attributeString;
}

+ (NSAttributedString *)setStrikeThroughText:(NSString *)text
                                        font:(UIFont *)font
                                       color:(UIColor *)textColor
                                       range:(NSRange)range
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:text];
    
    NSMutableDictionary *attDic = [[NSMutableDictionary alloc] init];
    
    if (font) {
        [attDic setValue:font forKey:NSFontAttributeName];
    }
    if (textColor) {
        [attDic setValue:textColor forKey:NSForegroundColorAttributeName];
    }
    [attDic setValue:[NSNumber numberWithInteger:NSUnderlineStyleSingle] forKey:NSStrikethroughStyleAttributeName];
    
    [attributeString setAttributes:attDic range:range];

    return attributeString;
}

@end
