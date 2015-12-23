//
//  SystemMessage.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/22.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "SystemMessage.h"
#import "CommonFile.h"
#import "HttpBaseFile.h"

#define FindSysMessage_URL                @"/org/findSysMessage.hz"//找到消息中心系统消息
#define ExamineUserApply_URL              @"/org/examineUserApply.hz"//审核成员加入

@implementation SystemMessage

+ (NSMutableArray*)findSysMessage:(NSString*)userID currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&page=%ld&pageSize=%ld",FindSysMessage_URL,userID, page, rowCount]];
    
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
                    NSInteger totalPages = 0;
                    if ([dataDic valueForKey:@"totalPages"] != nil) {
                        totalPages = [[dataDic valueForKey:@"totalPages"] integerValue];
                    }
                    
                    id dataArr = [dataDic valueForKey:@"datalist"];
                    if ([dataArr isKindOfClass:[NSArray class]])
                    {
                        NSArray* dArr = (NSArray*)dataArr;
                        
                        for (id data in dArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                SystemMessage* cm = [SystemMessage new];
                                
                                cm.createTime = [di valueForKey:@"createTime"];
                                cm.title = [di valueForKey:@"title"];
                                cm.source = [di valueForKey:@"source"];
                                cm.status = [di valueForKey:@"status"];
                                cm.userName = [di valueForKey:@"userName"];
                                cm.orgName = [di valueForKey:@"orgName"];
                                cm.wgName = [di valueForKey:@"wgName"];
                                cm.mobile = [di valueForKey:@"mobile"];
                                cm.createId = [[di valueForKey:@"createId"] stringValue];
                                cm.sourceId = [[di valueForKey:@"sourceId"] stringValue];
                                cm.totalPages = totalPages;
                                
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

+ (BOOL)examineUserApply:(NSString*)requestId status:(NSString *)status;
{
    BOOL re = NO;
    
    if (requestId) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:requestId forKey:@"id"];
        [dic setObject:status forKey:@"status"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:ExamineUserApply_URL postData:dic];
        
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
