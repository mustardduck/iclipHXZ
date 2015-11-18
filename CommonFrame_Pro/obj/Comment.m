//
//  Comment.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/22.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Comment.h"
#import "HttpBaseFile.h"
#import "CommonFile.h"
#import "LoginUser.h"
#import "CommonFile.h"

#define CURL                    @"/task/createTaskComment.hz"
#define PRAISE_URL              @"/task/commentThumbsUp.hz"
#define DELETECOMMENT_URL       @"/task/deleteTaskComment.hz"
#define CREATECOMMENTACCESSORY  @"/task/createCommentAccessory.hz"

@implementation Comment

- (BOOL)createCommentAccessory:(NSMutableDictionary *)commAccDic
{
    BOOL isOk = NO;
        
    NSString* jsonStr = [CommonFile toJson:commAccDic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:CREATECOMMENTACCESSORY postData:tmpDic];
                                                                                                                                                                                                                            
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
            }
        }
    }
    
    return isOk;
}

- (BOOL)createCommentAccessoryId:(NSMutableDictionary **)commDic
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:self.taskId forKey:@"taskId"];
    [dic setObject:self.userId forKey:@"userId"];
    [dic setObject:[NSString stringWithFormat:@"%ld",self.level] forKey:@"level"];
    [dic setObject:self.main forKey:@"main"];
    [dic setObject:self.parentId forKey:@"parentId"];
    [dic setObject:@"1" forKey:@"status"];
    [dic setObject:@"1" forKey:@"isAccessory"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:CURL postData:dic];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    * commDic = dataDic;
                }
            }
        }
        
    }
    
    return isOk;
}

- (BOOL)sendComment
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    
    [dic setObject:self.taskId forKey:@"taskId"];
    [dic setObject:self.userId forKey:@"userId"];
    [dic setObject:[NSString stringWithFormat:@"%ld",self.level] forKey:@"level"];
    [dic setObject:self.main forKey:@"main"];
    [dic setObject:self.parentId forKey:@"parentId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithASyncByPost:CURL postData:dic];//requestDataWithASyncByPost("A")
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
            }
        }
        
    }
    
    return isOk;
}

- (BOOL)deleteTaskComment:(NSString *) commentsId taskId:(NSString *) taskId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    [dic setObject:[LoginUser loginUserID] forKey:@"userId"];
    
    [dic setObject:commentsId forKey:@"commentsId"];
    
    [dic setObject:taskId forKey:@"taskId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:DELETECOMMENT_URL postData:dic];

    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);

            }
        }
    }
    
    return isOk;
}

- (BOOL)sendComment:(NSString**)commentId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:self.taskId forKey:@"taskId"];
    [dic setObject:self.userId forKey:@"userId"];
    [dic setObject:[NSString stringWithFormat:@"%ld",self.level] forKey:@"level"];
    [dic setObject:self.main forKey:@"main"];
    [dic setObject:self.parentId forKey:@"parentId"];
    [dic setObject:@"1" forKey:@"status"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:CURL postData:dic];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    NSString* cid = [dataDic valueForKey:@"commentsId"];
                    *commentId = cid;
                }
            }
        }
        
    }
    
    return isOk;
}

+ (BOOL)praise:(NSString*)commentId workGroupId:(NSString*)wgid hasPraised:(BOOL)isPraise
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    
    [dic setObject:commentId forKey:@"commentsId"];
    [dic setObject:[LoginUser loginUserID] forKey:@"userId"];
    [dic setObject:wgid forKey:@"workGroupId"];
    [dic setObject:(isPraise?@"1":@"0") forKey:@"status"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:PRAISE_URL postData:dic];
    
    if (responseString == nil) {
        return NO;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                NSLog(@"Dic:%@",dic);
                return YES;
            }
        }
        
    }

    
    
    return NO;
}


@end
