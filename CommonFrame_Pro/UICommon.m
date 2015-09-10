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
    CGSize size = CGSizeMake(MAXFLOAT, H(label));
    if ([UICommon getSystemVersion] > 7.0)//IOS 7.0 以上
    {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:label.font, NSFontAttributeName,nil];
        size =[label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }
    else
    {
        size = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];//ios7以上已经摒弃的这个方法
    }
    
    return size;
}

+(float)getSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (UIViewController *)getOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController
{
    id ret = nil;
    
    NSArray *array = navController.viewControllers;
    
    if (!array && array.count == 0) return nil;
    
    for (id object in array)
    {
        if ([object isKindOfClass:[viewCon class]])
        {
            ret = object;
        }
    }
    UIViewController *popTarget = ret;
    return popTarget;
}

+ (void)popOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController
{
    UIViewController *model =  [self getOldViewController:viewCon withNavController:navController];
    if (model && [model isKindOfClass:[UIViewController class]])
        [navController popToViewController:model animated:YES];
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

+ (NSString*) formatTime:(NSString*)input withLength:(int)length{
    
    if ([input length] == 0) {
        
        return @"";
    }
    
    NSString *text = [input stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
    if ([text length] > length) {
        
        text = [text substringToIndex:length];
    }
    
    return text;
}

@end

@implementation UIViewController (expanded)

- (void) hiddenKeyboard{}

- (void) addDoneToKeyboard:(UIView *)activeView
{
    //定义完成按钮
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    [topView setBarStyle:UIBarStyleBlack];
    if ([UICommon getSystemVersion] < 7.0)
    {
        [topView setTintColor:RGBCOLOR(174, 178, 185)];
    }
    else
    {
        [topView setBarTintColor:RGBCOLOR(174, 178, 185)];
    }
    
    UIBarButtonItem * button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyboard)];
    
    doneButton.tintColor = RGBCOLOR(85, 85, 85);
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    if([activeView isKindOfClass:[UITextField class]])
    {
        UITextField * text = (UITextField *)activeView;
        
        [text setInputAccessoryView:topView];
        
    }
    else
    {
        UITextView * textView = (UITextView *)activeView;
        
        [textView setInputAccessoryView:topView];
    }
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

+ (UIColor *) cellHoverBackgroundColor
{
    return RGBCOLOR(43, 42, 47);
}

@end
