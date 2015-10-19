//
//  CommonFile.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/14.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "CommonFile.h"
//#import <SBJson4Parser.h>

@implementation CommonFile

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (uint32_t)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

+ (id)jsonNSDATA:(NSData*)response
{
    id val = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
    return val;
}

//+ (id)json:(NSString*)jsonString
//{
//    __block id reVal;
//    
//    SBJson4ValueBlock block = ^(id v,BOOL *STOP)
//    {
//        BOOL isArray = [v isKindOfClass:[NSArray class]];
//        NSLog(@"Found: %@", isArray ? @"Array" : @"Object");
//        reVal = v;
//    };
//    
//    SBJson4ErrorBlock eh = ^(NSError* err) {
//        NSLog(@"OOPS: %@", err);
//    };
//    
//    id parser = [SBJson4Parser multiRootParserWithBlock:block
//                                           errorHandler:eh];
//    
//    id data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    [parser parse:data];
//    
//    NSArray* aa = @[@"aaaa",@"bbb"];
//    
//    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:aa];
//    [parser parse:data1];
//    
//    return reVal;
//
//}

+ (NSString*)toJson:(id)theData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        NSString *aString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return aString;
    }else{
        return nil;
    }
}

+ (void)saveInfoWithKey:(id)value withKey:(NSString*)key
{
    
    if ([value isKindOfClass:[NSData class]] || [value isKindOfClass:[NSString class]]
        || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]]
        || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]])
    {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:value forKey:key];
    }
}

+ (id)getInfoWithKey:(NSString*)key
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    id resu = [userDefaults valueForKey:key];
    
    return resu;
}

+ (void)removeInfoWithKey:(NSString*)key
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
}

+ (id)getPreInfoWithKey:(NSString*)key
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    
    return [CommonFile getInfoWithKey:key];
}

+ (void)InfoSync
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
}


+(CGSize)contentSize:(NSString*)content vWidth:(CGFloat)width vHeight:(CGFloat)height contentFont:(UIFont*)font
{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize size = [content boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingTruncatesLastVisibleLine |
                   NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return  CGSizeMake(size.width + 2, size.height+2);
}

+ (NSString*)saveImageToDocument:(NSData *)data fileName:(NSString*)imageName
{
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    NSString* filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  [NSString stringWithFormat:@"/%@",imageName]];
    
    return filePath;
}

+(NSArray*)getFileFromDocument
{
    NSMutableArray* arr = [NSMutableArray array];
    
    NSFileManager* manage = [NSFileManager defaultManager];
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSError* err;
    NSArray* tmAr = [manage contentsOfDirectoryAtPath:DocumentsPath error:&err];
    
    for (NSString* fileName in tmAr)
    {
        NSString* filePath = [DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
        if ([fileName containsString:@".png"]||[fileName containsString:@".PNG"]||[fileName containsString:@".jpg"]||[fileName containsString:@".JPG"])
        {
            //NSDictionary* dic = [manage attributesOfItemAtPath:filePath error:&err];
            //UIImage* img = [UIImage imageWithContentsOfFile:filePath];
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            [dic setObject:filePath forKey:fileName];
            
            [arr addObject:dic];
        }
        else if ([fileName containsString:@".pdf"]||[fileName containsString:@".PDF"])
        {
            [arr addObject:fileName];
        }
        
    }
    
    return arr;
}

+(NSDate*) convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:uiDate];
    
    return destDate;
}


@end
