//
//  Authority.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/21.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Authority.h"
#import "HttpBaseFile.h"
#import "CommonFile.h"

#define CURL                    @"/workgroup/findWgPeopleRole.hz"
#define CHANGE_AUTHORITY        @"/workgroup/updateWgPeopleRole.hz"

@implementation Authority

+ (NSArray*)getMemberRoleArrayByWorkGroupIDAndWorkContractID:(NSString*)workgroupId WorkContractID:(NSString*)contractId
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&workContactsId=%@",CURL,workgroupId,contractId]];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    id ddic = [dataDic valueForKey:@"allList"];
                    
                    if ([ddic isKindOfClass:[NSArray class]]) {
                        
                        NSArray* dArr = (NSArray*)ddic;
                        
                        for (id data in dArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                Authority* cm = [Authority new];
                                
                                cm.wgRoleId = [[di valueForKey:@"wgRoleId"] integerValue];
                                cm.wgRoleName = [di valueForKey:@"wgRoleName"];
                                cm.remark = [di valueForKey:@"remark"];
                                cm.isHave = [[di valueForKey:@"isHave"] boolValue];
                                
                                [array addObject:cm];
                                
                            }
                        }
                    }

                }
                
            }
        }
        
    }
    
    
    return array;
}

+ (BOOL)changeMemberAuthority:(NSArray*)authorityArray workContractID:(NSString*)contractId
{
    BOOL re = NO;
    
    if (authorityArray.count > 0 ) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        NSString* auStr = @"";
        
        int i = 0;
        for (NSString* str in authorityArray) {
            i++;
            auStr = [auStr stringByAppendingString:str];
            if (i < authorityArray.count) {
                auStr = [auStr stringByAppendingString:@","];
            }
        }
        
        [dic setObject:contractId forKey:@"workContactsId"];
        [dic setObject:auStr forKey:@"str"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:CHANGE_AUTHORITY postData:dic];
        
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
