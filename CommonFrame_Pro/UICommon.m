//
//  UICommon.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/8/4.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "UICommon.h"

@implementation UICommon

+ (CGSize)getWidthFromLabel:(UILabel *)label
{
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(MAXFLOAT, label.frame.size.height)];
    if (size.width > 320) size.width -= 320;
    return size;
}

+(float)getSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGSize) getSizeFromString:(NSString *)str withSize:(CGSize)cSize withFont:(CGFloat)fontsize
{
    CGSize size = CGSizeZero;
    
    if([UICommon getSystemVersion] >= 7.0)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:Font(fontsize),NSFontAttributeName,[NSParagraphStyle defaultParagraphStyle],NSParagraphStyleAttributeName, nil];
        
        size = [str boundingRectWithSize:cSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        size.height = ceil(size.height);
        
        size.width = ceil(size.width);
    }
    else
    {
        size = [str sizeWithFont:Font(fontsize) constrainedToSize:cSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return size;
}

+ (CGSize)getHeightFromLabel:(UILabel *)label
{
    NSDictionary *attribute = @{NSFontAttributeName: label.font};
    
    CGSize retSize = CGSizeZero;
    
    if([UICommon getSystemVersion] >= 7.0)
    {
        retSize = [label.text boundingRectWithSize:CGSizeMake(W(label), MAXFLOAT)
                   
                                           options:\
                   
                   NSStringDrawingTruncatesLastVisibleLine |
                   
                   NSStringDrawingUsesLineFragmentOrigin |
                   
                   NSStringDrawingUsesFontLeading
                   
                                        attributes:attribute
                   
                                           context:nil].size;
    }
    else
        retSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(W(label), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat ret = (H(label) - retSize.height)/2;
    retSize.height += ret;
    return retSize;
}

+ (NSString *)dayAndHourFromString:(NSString *)dateString formatStyle:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];;
    [formatter setDateFormat:format];
    return [formatter stringFromDate:destDate];

}

@end

@implementation UIColor (Addition)

+ (UIColor *) disableGreyColor
{
    return RGBCOLOR(99, 99, 102);
}

+ (UIColor *) greyStatusBarColor
{
    return RGBCOLOR(35, 34, 39);
}


@end
