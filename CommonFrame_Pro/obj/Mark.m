//
//  Mark.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Mark.h"
#import "LoginUser.h"

#define NEW_URL             @"/workgroup/addWgLabel.hz"
#define DELETE_URL          @"/workgroup/deleteWgLabel.hz"
#define UPDATE_URL          @"/workgroup/updateWgLabel.hz"
#define UPDATE_MEM_URL      @"/workgroup/updateWgPeopleLabel.hz"

@implementation Mark

+ (NSArray*)getMarkListByWorkGroupID:(NSString*)workGroupId loginUserID:(NSString*)userid andUrl:(NSString *)url
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSString* responseString = @"";
    
    if([url isEqualToString:CURL])
    {
        responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&levelStr=1,2&statusStr=1",url,workGroupId]];
    }
    else
    {
        responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&levelStr=1,2&statusStr=1&userId=%@",url,workGroupId,userid]];
    }
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile json:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSArray class]])
                {
                    
                    NSArray* dArr = (NSArray*)dataDic;
                    
                    for (id data in dArr) {
                        if ([data isKindOfClass:[NSDictionary class]]) {
                            
                            NSDictionary* di = (NSDictionary*)data;
                            
                            Mark* cm = [Mark new];
                            
                            cm.labelId = [di valueForKey:@"labelId"];
                            cm.labelName = [di valueForKey:@"labelName"];
                            cm.isSystem = [[di valueForKey:@"level"] intValue] == 1?YES:NO;
                            
                            [array addObject:cm];
                            
                        }
                    }
                }
            }
        }
        
    }
    
    return array;
}

+ (BOOL)createNewMark:(NSString*)labelName workGroupID:(NSString*)workGroupId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:workGroupId forKey:@"workGroupId"];
    [dic setObject:labelName forKey:@"labelName"];

    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:NEW_URL postData:dic];
    
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

+ (BOOL)remove:(NSString*)labelID workGroupId:(NSString*)wgid
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    [dic setObject:labelID forKey:@"labelId"];
    [dic setObject:@"-1" forKey:@"status"];
    [dic setObject:wgid forKey:@"workGroupId"];
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:DELETE_URL postData:dic];
    
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

+ (BOOL)update:(NSString*)labelID labelName:(NSString*)name
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:labelID forKey:@"labelId"];
    [dic setObject:name forKey:@"labelName"];
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_URL postData:dic];
    
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

+ (BOOL)updateMarkMember:(NSString*)labelID workGroupID:(NSString*)workGroupId memberIdArray:(NSArray*)memberIDArray
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* mIdStr = @"";
    int i = 0;
    for (NSString* idStr in memberIDArray) {
        i++;
        NSString* t = [NSString stringWithFormat:@"%@",idStr];
        
        mIdStr = [mIdStr stringByAppendingString:t];
        if (i < memberIDArray.count) {
            mIdStr = [mIdStr stringByAppendingString:@","];
        }
    }
    
    [dic setObject:labelID forKey:@"labelId"];
    [dic setObject:workGroupId forKey:@"workGroupId"];
    [dic setObject:mIdStr forKey:@"str"];
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_MEM_URL postData:dic];
    
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


@end
