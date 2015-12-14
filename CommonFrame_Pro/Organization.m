//
//  Organization.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/14.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "Organization.h"

#define FIND_ORG_URL        @"/org/findOrgbyStr.hz"
#define ADD_ORG_USER_URL        @"/org/addOrgUser.hz"
#define ADD_ORG_URL        @"/org/addOrg.hz"

@implementation Organization

+ (NSArray*)findOrgbyStr:(NSString*)userID str:(NSString *)str
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&str=%@",FIND_ORG_URL,userID,(str == nil ? @"" : [NSString stringWithFormat:@"&str=%@",str])]];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataArr = [dic valueForKey:@"data"];
                
                if ([dataArr isKindOfClass:[NSArray class]])
                {
                    NSArray* dArr = (NSArray*)dataArr;

                    for (id data in dArr) {
                        if ([data isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary* di = (NSDictionary*)data;
                            
                            Organization* org = [Organization new];
                            
                            org.logo = [di valueForKey:@"logo"];
                            org.name = [di valueForKey:@"name"];
                            org.orgId = [di valueForKey:@"organizationId"];
                            org.createName = [di valueForKey:@"createName"];
                            org.createUserId = [di valueForKey:@"createUserId"];
                            org.status = [di valueForKey:@"status"];
                            
                            [array addObject:org];
                        }
                    }
                }
            }
        }
        
    }
    
    return array;
}

+ (BOOL)addOrgUser:(NSString*)userID orgId:(NSString *)orgId
{
    BOOL re = NO;
    
    if (orgId) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:orgId forKey:@"orgId"];
        [dic setObject:userID forKey:@"userId"];
        [dic setObject:@"2" forKey:@"platform"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:ADD_ORG_USER_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return re;
}

+ (BOOL)addOrg:(NSString*)userID orgName:(NSString *)orgName
{
    BOOL re = NO;
    
    if (orgName) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:orgName forKey:@"orgName"];
        [dic setObject:userID forKey:@"userId"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:ADD_ORG_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return re;
}

@end
