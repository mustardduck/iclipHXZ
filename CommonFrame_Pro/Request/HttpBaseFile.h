//
//  HttpBaseFile.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/14.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>
#import <ASIDataCompressor.h>
#import <ASIDownloadCache.h>

@interface HttpBaseFile : NSObject

+ (NSData*)requestDataWithSyncByPost:(NSString*)urlStr postData:(NSDictionary*)data;
+ (NSData*)requestDataWithSync:(NSString*)urlStr;
+ (NSData*)requestDataWithSyncByPostContansBaseURL:(NSString*)urlStr postData:(NSDictionary*)data;

+ (NSData*)requestDataWithASyncByPost:(NSString*)urlStr postData:(NSDictionary*)data;
+ (NSData*)requestDataWithASync:(NSString*)urlStr;

+ (NSString*)baseURL;

+ (NSData*)requestImageWithSyncByPost:(NSString*)urlStr withFilePath:(NSString *)filePath;

@end
