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

+ (NSString*)requestDataWithSyncByPost:(NSString*)urlStr postData:(NSDictionary*)data;
+ (NSString*)requestDataWithSync:(NSString*)urlStr;
+ (NSString*)requestDataWithSyncByPostContansBaseURL:(NSString*)urlStr postData:(NSDictionary*)data;

+ (NSString*)requestDataWithASyncByPost:(NSString*)urlStr postData:(NSDictionary*)data;
+ (NSString*)requestDataWithASync:(NSString*)urlStr;

+ (NSString*)baseURL;

+ (NSString*)requestImageWithSyncByPost:(NSString*)urlStr withFilePath:(NSString *)filePath;

@end
