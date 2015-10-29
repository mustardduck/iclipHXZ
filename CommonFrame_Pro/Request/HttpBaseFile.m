//
//  HttpBaseFile.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/14.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "HttpBaseFile.h"

#define BASE_URL @"http://www.iclip365.com:8080/clip_basic"
//120.26.113.44 (release) // www.iclip365.com
//测试服ip    10.0.1.200
//10.0.1.8(lijun local)


@implementation HttpBaseFile

+ (NSString*)baseURL
{
    return BASE_URL;
}

+ (NSData*)requestDataWithSyncByPost:(NSString*)urlStr postData:(NSDictionary*)data
{
    NSData* res = nil;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlStr]];
    
    ASIFormDataRequest* requestForm = [[ASIFormDataRequest alloc] initWithURL:url];
    
    for (NSString* key in data.allKeys) {
        
        [requestForm setPostValue:[data valueForKey:key] forKey:key];
    }
        
    [requestForm setRequestMethod:@"POST"];
    
    [requestForm startSynchronous];
    
    res = [requestForm responseData];
    
    return res;
}

+ (NSData*)requestImageWithSyncByPost:(NSString*)urlStr withFilePath:(NSString *)filePath
{
    NSData* res = nil;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlStr]];
    
    ASIFormDataRequest* requestForm = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [requestForm setDelegate:self];
    [requestForm setRequestMethod:@"POST"];
    [requestForm addRequestHeader:@"Content-Type" value:@"image/jpg"];
    [requestForm setFile:filePath forKey:@"photo"];
    [requestForm setUploadProgressDelegate:self];
    [requestForm setShowAccurateProgress:YES];
    
    [requestForm startSynchronous];
    
    res = [requestForm responseData];
    
    return res;
}

+ (NSString*)requestDataWithSyncByPostContansBaseURL:(NSString*)urlStr postData:(NSDictionary*)data
{
    NSString* res = nil;
    
    NSURL* url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest* requestForm = [[ASIFormDataRequest alloc] initWithURL:url];
    
    for (NSString* key in data.allKeys) {
        
        [requestForm setPostValue:[data valueForKey:key] forKey:key];
    }
    
    [requestForm setRequestMethod:@"POST"];
    
    [requestForm startSynchronous];
    
    res = [requestForm responseString];
    
    return res;
}

+ (NSData*)requestDataWithSync:(NSString *)urlStr
{
    NSData *response = nil;
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* fullURLStr = [NSString stringWithFormat:@"%@%@",BASE_URL,urlStr];
    NSLog(@"%@",fullURLStr);
    
    NSURL* url = [NSURL URLWithString:fullURLStr];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setRequestMethod:@"GET"];
    //[request setDelegate:self];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error) {
        response = [request responseData];
    }
    
    return response;
}


+ (NSData*)requestDataWithASyncByPost:(NSString*)urlStr postData:(NSDictionary*)data
{
    __block NSData *resString = nil;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlStr]];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    
    for (NSString* key in data.allKeys) {
        
        [request setPostValue:[data valueForKey:key] forKey:key];
    }
    
    [request setRequestMethod:@"POST"];
    
    [request setCompletionBlock:^{
        
        resString = [request responseData];
        NSLog(@"%@",resString);
        //NSData* resData = [request responseData];
    }];
    
    
    __block NSError* err;
    [request setFailedBlock:^{
    
        err = [request error];
        NSLog(@"ASync Request Error: %@",[err description]);
    }];
    
    [request startAsynchronous];
    
    return resString;
}

+ (NSData*)requestDataWithASync:(NSString*)urlStr
{
    __block NSData *resString = nil;
    
     urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlStr]];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:url];

    __block ASIHTTPRequest* requ = request;
    
    [request setCompletionBlock:^{
        
        resString = [request responseData];
        //NSData* resData = [request responseData];
    }];
    
    [request setFailedBlock:^{
        
        NSError* err = [requ error];
        NSLog(@"ASync Request Error: %@",[err userInfo]);
    }];
    
    [request startAsynchronous];
    
    return resString;
}

@end
