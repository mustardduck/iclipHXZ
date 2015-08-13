//
//  Group.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Group.h"

#define CURL                @"/index/findIndexMessageNum.hz"
#define WORKLIST_URL        @"/workgroup/findMeWgList.hz"
#define INVITE_URL          @"/workgroup/inviteUser.hz"
#define NEW_GROUP           @"/workgroup/addWorkgroup.hz"
#define DETAIL_URL          @"/workgroup/intoWorkgroupDetail.hz"
#define UPDATE_URL          @"/workgroup/updateWorkgroup.hz"

@implementation Group

+ (NSArray*)getGroupsByUserID:(NSString*)userID marks:(NSArray**)markArray  searchString:(NSString*)str
{
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray* marks = [NSMutableArray array];
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@%@",CURL,userID,(str == nil ? @"" : [NSString stringWithFormat:@"&str=%@",str])]];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile json:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    id dataArr = [dataDic valueForKey:@"wglist"];
                    if ([dataArr isKindOfClass:[NSArray class]])
                    {
                        NSArray* dArr = (NSArray*)dataArr;
                        
                        for (id data in dArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                Group* cm = [Group new];
                                
                                cm.messageCount = [NSString stringWithFormat:@"%d",[[di valueForKey:@"num"] intValue]];
                                cm.workGroupImg = [di valueForKey:@"workGroupImg"];
                                cm.isAdmin = [[di valueForKey:@"isAdmin"] boolValue];
                                cm.workGroupId = [di valueForKey:@"workGroupId"];
                                cm.workGroupName = [di valueForKey:@"workGroupName"];
                                cm.workGroupMain = [di valueForKey:@"workGroupMain"];
                                
                                [array addObject:cm];
                                
                            }
                        }
                        
                    }
                    
                    
                    id markArr = [dataDic valueForKey:@"sortlist"];
                    if ([markArr isKindOfClass:[NSArray class]])
                    {
                        NSArray* dArr = (NSArray*)markArr;
                        NSArray *imageList = @[@"icon_youshijian", @"icon_youfabu",@"icon_youhuifu", @"icon_you7", @"icon_you30",@"icon_you365", @"icon_youbiaoqian_1"];
                        int i = 0;
                        for (id data in dArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                Mark* m = [Mark new];
                                
                                if ([di valueForKey:@"indexSortName"] != nil) {
                                    NSString* markName = [di valueForKey:@"indexSortName"];
                                    m.labelName = markName;
                                    m.labelId = [di valueForKey:@"id"];
                                    m.labelImage = [imageList objectAtIndex:i];
                                    [marks addObject:m];
                                }
                                else if ([di valueForKey:@"labelName"] != nil)
                                {
                                    NSString* markName = [di valueForKey:@"labelName"];
                                    
                                    m.labelName = markName;
                                    m.labelId = [di valueForKey:@"labelId"];
                                    m.labelImage = @"icon_youbiaoqian_2";
                                    
                                    [marks addObject:m];
                                }
                            }
                            i++;
                        }
                        
                    }
                }
            }
        }
        
    }
    
    *markArray = marks;
    
    return array;
}

+ (NSArray*)getWorkGroupListByUserID:(NSString*)userID
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@",WORKLIST_URL,userID]];
    
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
                            
                            Group* cm = [Group new];
                            
                            cm.messageCount = [NSString stringWithFormat:@"%d",[[di valueForKey:@"num"] intValue]];
                            cm.workGroupImg = [di valueForKey:@"workGroupImg"];
                            cm.workGroupId = [di valueForKey:@"workGroupId"];
                            cm.workGroupName = [di valueForKey:@"workGroupName"];
                            cm.workGroupMain = [di valueForKey:@"workGroupMain"];
                            cm.isAdmin = [[di valueForKey:@"isAdmin"] boolValue];
                            
                            [array addObject:cm];
                            
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    return array;
}

+ (BOOL)inviteNewUser:(NSString*)loginUserId workGroupId:(NSString*)workGroupId source:(NSInteger)source sourceValue:(NSString*)sourceStr
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    [dic setObject:loginUserId forKey:@"userId"];
    [dic setObject:workGroupId forKey:@"workGroupId"];
    [dic setObject:[NSString stringWithFormat:@"%ld",source] forKey:@"source"];
    [dic setObject:sourceStr forKey:@"sourceStr"];
     [dic setObject:@"2" forKey:@"platform"];
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:INVITE_URL postData:dic];
    
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

+ (BOOL)createNewGroup:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:workGroupName forKey:@"workGroupName"];
    [dic setObject:workGroupMain forKey:@"workGroupMain"];
    [dic setObject:img forKey:@"img"];
    [dic setObject:@"1015050511520001" forKey:@"orgId"];
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:NEW_GROUP postData:dic];
    
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

+ (BOOL)updateGroup:(NSString*)wgid name:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:workGroupName forKey:@"workGroupName"];
    [dic setObject:workGroupMain forKey:@"workGroupMain"];
    [dic setObject:img forKey:@"img"];
    [dic setObject:wgid forKey:@"workGroupId"];
    
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

+ (NSArray*)groupAuthoryByWorkGroupId:(NSString*)workGroupId isAdmin:(NSString**)admin
{
    NSMutableArray* array = [NSMutableArray array];
    NSString* isAdmin = @"";
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&userId=%@",DETAIL_URL,workGroupId,[LoginUser loginUserID]]];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile json:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary* dArr = (NSDictionary*)dataDic;
                    
                    if ([dArr valueForKey:@"isAdmin"] != nil) {
                        isAdmin = [dArr valueForKey:@"isAdmin"];
                    }
                    
                    id listArr = [dArr valueForKey:@"list"];
                    
                    if ([listArr isKindOfClass:[NSArray class]])
                    {
                        for (id data in listArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                Group* cm = [Group new];
                                
                                cm.workGroupId = [di valueForKey:@"wgRoleId"];
                                cm.workGroupName = [di valueForKey:@"wgRoleName"];
                                
                                [array addObject:cm];
                                
                            }
                        }
                    }
                    
                    
                    
                }
                
            }
        }
        
    }
    
    *admin = isAdmin;
    
    return array;
}


@end
