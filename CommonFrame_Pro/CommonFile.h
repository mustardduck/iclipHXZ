//
//  CommonFile.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/14.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>

@interface CommonFile : NSObject

+ (NSString *)md5:(NSString *)str;

+ (id)json:(NSString*)jsonString;
+ (NSString*)toJson:(id)obj;

+ (void)saveInfoWithKey:(id)value withKey:(NSString*)key;
+ (id)getInfoWithKey:(NSString*)key;
+ (void)removeInfoWithKey:(NSString*)key;
+ (id)getPreInfoWithKey:(NSString*)key;
+ (void)InfoSync;
+(NSDate*)convertDateFromString:(NSString*)uiDate;
+(NSString*)saveImageToDocument:(NSData *)data fileName:(NSString*)imageName;
+(NSArray*)getFileFromDocument;

+(CGSize)contentSize:(NSString*)content vWidth:(CGFloat)width vHeight:(CGFloat)height contentFont:(UIFont*)font;
@end
