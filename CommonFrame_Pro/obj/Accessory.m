//
//  Accessory.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Accessory.h"
#import "CommonFile.h"
#import "LoginUser.h"

#define Accessory_INFO           @"/workgroup/findWgAccessory.hz"

@implementation Accessory

+(Accessory*)jsonToObj:(NSData *)jsonString
{
    id val = [CommonFile jsonNSDATA:jsonString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary* di = (NSDictionary*)dataDic;
                    
                    Accessory* cm = [Accessory new];
                    
                    cm.address = [di valueForKey:@"path"];
                    cm.name = [di valueForKey:@"oldName"];
                    //cm.jsonStr = jsonString;
                    cm.size = [di valueForKey:@"size"];
                    
                    return cm;
                }
                
            }
        }
        
    }
    return nil;
}

+ (NSArray*)getAccessoryListByWorkGroupID:(NSString*)workGroupId
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&userId=%@",Accessory_INFO, workGroupId, [LoginUser loginUserID]]];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
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
                            
                            Accessory* cm = [Accessory new];
                            
                            cm.isComplete = [[di valueForKey:@"isComplete"] intValue] == 1?YES:NO;
                            cm.source = [[di valueForKey:@"source"] integerValue];
                            cm.breakpointSize = [[di valueForKey:@"breakpointSize"] integerValue];
                            cm.status = [[di valueForKey:@"status"] boolValue];
                            cm.address = [di valueForKey:@"address"];
                            cm.name = [di valueForKey:@"name"];
                            cm.type = [[di valueForKey:@"type"] integerValue];
                            cm.size = [di valueForKey:@"size"];
                            cm.sourceId = [di valueForKey:@"sourceId"];
                            cm.addTime = [di valueForKey:@"addTime"];
                            cm.userName = [di valueForKey:@"userName"];
                            cm.userImg = [di valueForKey:@"userImg"];
                            [array addObject:cm];
                            
                        }
                    }
                }
            }
        }
        
    }
    
    return array;
}

@end
