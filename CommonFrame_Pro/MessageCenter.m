//
//  MessageCenter.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/23.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MessageCenter.h"
#import "HttpBaseFile.h"
#import "CommonFile.h"
#import "LoginUser.h"

#define MESSAGECENTER_LIST_URL            @"/index/findMessageCenter.hz"


@implementation MessageCenter

+ (NSMutableArray*)getMessageListByUserID:(NSString*)userID currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&page=%ld&pageSize=%ld",MESSAGECENTER_LIST_URL,[LoginUser loginUserID], page, rowCount]];
    
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
                                
                                MessageCenter* cm = [MessageCenter new];
                                
                                cm.commentText = [di valueForKey:@"content"];
                                cm.megId = [[di valueForKey:@"id"] stringValue];
                                cm.createTime = [di valueForKey:@"createTime"];
                                cm.taskId = [di valueForKey:@"taskId"];
                                cm.source = [di valueForKey:@"source"];
                                cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                                cm.userName = [di valueForKey:@"userName"];
                                cm.userImg = [di valueForKey:@"userImg"];
                                cm.rightImg = [di valueForKey:@"url"];                                
                                cm.missionText = [di valueForKey:@"main"];
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
@end
