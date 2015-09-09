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

#define CURL                @"/task/createTaskComment.hz"
#define PRAISE_URL          @"/task/commentThumbsUp.hz"

@implementation Comment


- (BOOL)sendComment
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    
    [dic setObject:self.taskId forKey:@"taskId"];
    [dic setObject:self.userId forKey:@"userId"];
    [dic setObject:[NSString stringWithFormat:@"%ld",self.level] forKey:@"level"];
    [dic setObject:self.main forKey:@"main"];
    [dic setObject:self.parentId forKey:@"parentId"];
    
    NSString* responseString = [HttpBaseFile requestDataWithASyncByPost:CURL postData:dic];//requestDataWithASyncByPost("A")
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile json:responseString];
    
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
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:CURL postData:dic];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile json:responseString];
    
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
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:PRAISE_URL postData:dic];
    
    if (responseString == nil) {
        return NO;
    }
    
    id val = [CommonFile json:responseString];
    
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
