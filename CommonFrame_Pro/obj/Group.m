//
//  Group.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Group.h"
#import "Mission.h"

#define CURL                @"/index/findIndexMessageNum.hz"
#define WORKLIST_URL        @"/workgroup/findMeWgList.hz"
#define INVITE_URL          @"/workgroup/inviteUserList.hz"
#define INVITE_USER_NEW_URL  @"/workgroup/inviteUserListNew.hz"

#define NEW_GROUP           @"/workgroup/addWorkgroup.hz"
#define DETAIL_URL          @"/workgroup/intoWorkgroupDetail.hz"
#define UPDATE_URL          @"/workgroup/updateWorkgroup.hz"
#define WORKLIST_SETTING_URL    @"/workgroup/findMeWgMessageList.hz"
#define UPDATE_GROUP_SETT_URL   @"/workgroup/updateWgSubscribeStatus.hz"
#define FindUserMainLabel_URL   @"/workgroup/findUserMainLabel.hz"
#define FindUserMainLabelTask_URL   @"/workgroup/findUserMainLabelTask.hz"
#define FindUserTaskByTime_URL          @"/workgroup/findUserTaskByTime.hz"



@implementation Group

+ (NSArray*)getGroupsByUserID:(NSString*)userID marks:(NSArray**)markArray workGroupId:(NSString *)workGroupId searchString:(NSString*)str allNum:(NSString **)allNum
{
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray* marks = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&workGroupId=%@%@",CURL,userID, workGroupId, (str == nil ? @"" : [NSString stringWithFormat:@"&str=%@",str])]];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * allNumStr = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
//                    allNumStr = [dataDic valueForKey:@"allNum"];
                    
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
                                cm.allNum = [di valueForKey:@"allNum"];

                                if(cm.workGroupId == workGroupId)
                                {
                                    allNumStr = cm.allNum;
                                }
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
                        NSArray *imageList = @[@"icon_youshijian", @"icon_youfabu",@"icon_youhuifu", @"icon_you7", @"icon_you30",@"icon_you365",@"icon_fabu", @"icon_renwu", @"icon_wenti", @"icon_jianyi", @"icon_qita", @"icon_youbiaoqian_1"];
                        
                        NSMutableArray * timeArr = [NSMutableArray array];
                        NSMutableArray * missionArr = [NSMutableArray array];
                        NSMutableArray * tagArr = [NSMutableArray array];

                        NSMutableArray * totalArr = [NSMutableArray array];
                        
                        int i = 0;
                        
                        for (id data in dArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                Mark* m = [Mark new];
                                
                                if ([di valueForKey:@"indexSortName"] != nil) {
                                    NSString* markName = [di valueForKey:@"indexSortName"];
                                    m.labelName = markName;
                                    m.labelId = [di valueForKey:@"indexSortId"];
                                    m.labelImage = [imageList objectAtIndex:i];
                                    
                                    if(i >= 0 && i <= 5)
                                    {
                                        [timeArr addObject:m];
                                    }
                                    else if (i >= 6 && i <= 10)
                                    {
                                        [missionArr addObject:m];
                                    }
                                    else
                                    {
                                        [tagArr addObject:m];
                                    }
                                }
                                else if ([di valueForKey:@"labelName"] != nil)
                                {
                                    NSString* markName = [di valueForKey:@"labelName"];
                                    
                                    m.labelName = markName;
                                    m.labelId = [di valueForKey:@"labelId"];
                                    m.labelImage = @"icon_youbiaoqian_1";
                                    [tagArr addObject:m];
//                                    [marks addObject:m];
                                }
                            }
                            i ++;
                        }
                        
                        [totalArr addObject:timeArr];
                        [totalArr addObject:missionArr];
                        [totalArr addObject:tagArr];
                        
                        [marks addObject:totalArr];
                    }
                }
            }
        }
        
    }
    
    *markArray = marks;
    
    *allNum = allNumStr;
    
    return array;
}

+ (NSArray*)findMeWgListByUserID:(NSString*)userID
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@",WORKLIST_URL,userID]];
    
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

+ (NSArray*)getWorkGroupListByUserID:(NSString*)userID selectArr:(NSMutableArray **)selectArr
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSMutableArray * selArr = [NSMutableArray array];
    
//    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@",WORKLIST_URL,userID]];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@",WORKLIST_SETTING_URL,userID]];
    
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
                            
                            Group* cm = [Group new];
                            
                            cm.messageCount = [NSString stringWithFormat:@"%d",[[di valueForKey:@"num"] intValue]];
                            cm.workGroupImg = [di valueForKey:@"workGroupImg"];
                            cm.workGroupId = [di valueForKey:@"workGroupId"];
                            cm.workGroupName = [di valueForKey:@"workGroupName"];
                            cm.workGroupMain = [di valueForKey:@"workGroupMain"];
                            cm.isAdmin = [[di valueForKey:@"isAdmin"] boolValue];
                            cm.isReceive = [[di valueForKey:@"status"] boolValue];
                            
                            if(cm.isReceive)
                            {
                                [selArr addObject:cm];
                            }
                            [array addObject:cm];
                            
                            
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    *selectArr = selArr;
    
    return array;
}

+ (BOOL)inviteNewUserList:(NSString*)loginUserId workGroupId:(NSString*)workGroupId inviteArr:(NSArray*)inviteArr
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:loginUserId forKey:@"userId"];
    if(workGroupId)
    {
        [dic setObject:workGroupId forKey:@"workGroupId"];
    }
    [dic setObject:@"1" forKey:@"platform"];
    [dic setObject:inviteArr forKey:@"vo"];
    
    NSString* jsonStr = [CommonFile toJson:dic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:INVITE_USER_NEW_URL postData:tmpDic];
    
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

+ (BOOL)inviteNewUser:(NSString*)loginUserId workGroupId:(NSString*)workGroupId source:(NSInteger)source sourceValue:(NSString*)sourceStr
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    [dic setObject:loginUserId forKey:@"userId"];
    [dic setObject:workGroupId forKey:@"workGroupId"];
    [dic setObject:@"0" forKey:@"source"];//  0:单位通讯录添加   1：短信邀请   2：邮件   3：工作组通讯录
    [dic setObject:sourceStr forKey:@"sourceStr"];
     [dic setObject:@"2" forKey:@"platform"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:INVITE_URL postData:dic];
    
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

+ (BOOL)createNewGroup:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img workGroupId:(NSString **)workGroupId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:workGroupName forKey:@"workGroupName"];
    [dic setObject:workGroupMain forKey:@"workGroupMain"];
    if(img.length)
    {
        [dic setObject:img forKey:@"img"];
    }
    else
    {
        [dic setObject:@"" forKey:@"img"];
    }
    
    [dic setObject:[LoginUser loginUserOrgID] forKey:@"orgId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:NEW_GROUP postData:dic];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * wgId = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
                
                NSDictionary * dicc = [dic objectForKey:@"data"];
                
                wgId = [dicc valueForKey:@"workGroupId"];
            }
        }
        
    }
    
    *workGroupId = wgId;
    
    return isOk;
}

+ (BOOL)updateGroup:(NSString*)wgid name:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    

    [dic setObject:workGroupName forKey:@"workGroupName"];
    [dic setObject:workGroupMain forKey:@"workGroupMain"];
    if(img)
    {
        [dic setObject:img forKey:@"img"];
    }
    else
    {
        [dic setObject:@"" forKey:@"img"];
    }
    
    [dic setObject:wgid forKey:@"workGroupId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_URL postData:dic];
    
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

+ (NSDictionary*)groupDicByWorkGroupId:(NSString*)workGroupId isAdmin:(NSString**)admin
{
    NSDictionary* dict = [NSDictionary dictionary];
    NSString* isAdmin = @"";
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&userId=%@",DETAIL_URL,workGroupId,[LoginUser loginUserID]]];
    
    if (responseString == nil) {
        return dict;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    dict = (NSDictionary *)dataDic;
                    
                    if ([dict valueForKey:@"isAdmin"] != nil) {
                        isAdmin = [dict valueForKey:@"isAdmin"];
                    }
                }
                
            }
        }
        
    }
    
    *admin = isAdmin;
    
    return dict;
}

+ (BOOL)updateWgSubscribeStatus:(NSString *)groupId isReceive:(BOOL) isReceive
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    NSString * status = @"1";
    if(!isReceive)
    {
        status = @"0";
    }
    [dic setObject:status forKey:@"status"];
    [dic setObject:groupId forKey:@"workGroupId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_GROUP_SETT_URL postData:dic];
    
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

+ (NSArray *) findUserMainLabel:(NSString *)userId workGroupId:(NSString *) workGroupId
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&workGroupId=%@",FindUserMainLabel_URL, userId, workGroupId]];
    
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
                            
                            Mark* ma = [Mark new];
                            ma.labelId = [di valueForKey:@"labelId"];
                            ma.labelName = [di valueForKey:@"labelName"];
                            
                            [array addObject:ma];
                        }
                    }
                }
            }
        }
    }
    
    return array;
}

+ (NSArray *) findUserMainLabelTask:(NSString *)userId workGroupId:(NSString *) workGroupId labelId:(NSString *)labelIdStr taskId:(NSString *)taskId
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&workGroupId=%@&labelIdStr=%@&taskId=%@",FindUserMainLabelTask_URL, userId, workGroupId, labelIdStr, taskId]];
    
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
                            
                            NSDictionary * labDic = (NSDictionary *)data;
                            
                            NSMutableArray * labelArr = [NSMutableArray array];
                            
                            NSArray * listArr = [labDic valueForKey:@"list"];
                            NSDictionary * labelDic = [labDic valueForKey:@"label"];
                            
                            for(id labData in listArr)
                            {
                                if([labData isKindOfClass:[NSDictionary class]])
                                {
                                    NSDictionary* di = (NSDictionary*)labData;
                                    
                                    Mission* mi = [Mission new];
                                    mi.taskId = [di valueForKey:@"taskId"];
                                    mi.title = [di valueForKey:@"title"];
                                    mi.status = [[di valueForKey:@"status"] integerValue];
                                    mi.finishTime = [di valueForKey:@"finishTimeStr"];
                                    mi.lableUserName = [di valueForKey:@"lableUserName"];//责任人
                                    mi.createUserId = [di valueForKey:@"createUserId"];
                                    mi.workGroupId = workGroupId;
                                    mi.isHave = [[di valueForKey:@"isHave"] integerValue];
                                    
                                    [labelArr addObject:mi];
                                }
                            }
                            
                            NSMutableDictionary * lddic = [NSMutableDictionary dictionary];
                            [lddic setObject:labelDic forKey:@"label"];
                            
                            NSNumber * num = [NSNumber numberWithInteger:[[labelDic valueForKey:@"labelId"] integerValue]];
                            [lddic setObject:labelArr forKey:num];
                            
                            [array addObject:lddic];
                        }
                    }
                }
            }
        }
    }
    
    return array;
}


+ (NSArray *) findUserTaskByTime:(NSString *)userId workGroupId:(NSString *) workGroupId
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSMutableArray * arrayNow = [NSMutableArray array];
    NSMutableArray * arraySeven = [NSMutableArray array];
    NSMutableArray * arraySevenAfter = [NSMutableArray array];

    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@&workGroupId=%@",FindUserTaskByTime_URL, userId, workGroupId]];
    
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
                            
                            NSArray * arr = [di objectForKey:@"now"];
                            
                            for(NSDictionary * mDic in arr)
                            {
                                Mission* mi = [Mission new];
                                mi.userName = [mDic valueForKey:@"createName"];
                                mi.createUserId = [mDic valueForKey:@"createUserId"];
                                mi.finishTime = [mDic valueForKey:@"finishTimeStr"];
                                mi.lableUserName = [mDic valueForKey:@"lableUserName"];
                                mi.status = [[mDic valueForKey:@"status"] integerValue];
                                mi.taskId = [mDic valueForKey:@"taskId"];
                                mi.title = [mDic valueForKey:@"title"];
                                
                                [arrayNow addObject:mi];

                            }
                            
                            NSArray * arrSeven = [di objectForKey:@"seven"];
                            
                            for(NSDictionary * mDic in arrSeven)
                            {
                                Mission* mi = [Mission new];
                                mi.userName = [mDic valueForKey:@"createName"];
                                mi.createUserId = [mDic valueForKey:@"createUserId"];
                                mi.finishTime = [mDic valueForKey:@"finishTimeStr"];
                                mi.lableUserName = [mDic valueForKey:@"lableUserName"];
                                mi.status = [[mDic valueForKey:@"status"] integerValue];
                                mi.taskId = [mDic valueForKey:@"taskId"];
                                mi.title = [mDic valueForKey:@"title"];
                                
                                [arraySeven addObject:mi];
                                
                            }
                            
                            NSArray * arrSevenAfter = [di objectForKey:@"sevenAfter"];
                            
                            for(NSDictionary * mDic in arrSevenAfter)
                            {
                                Mission* mi = [Mission new];
                                mi.userName = [mDic valueForKey:@"createName"];
                                mi.createUserId = [mDic valueForKey:@"createUserId"];
                                mi.finishTime = [mDic valueForKey:@"finishTimeStr"];
                                mi.lableUserName = [mDic valueForKey:@"lableUserName"];
                                mi.status = [[mDic valueForKey:@"status"] integerValue];
                                mi.taskId = [mDic valueForKey:@"taskId"];
                                mi.title = [mDic valueForKey:@"title"];
                                
                                [arraySevenAfter addObject:mi];
                                
                            }
                        }
                    }
                    
                    [array addObject:arrayNow];
                    [array addObject:arraySeven];
                    [array addObject:arraySevenAfter];
                }
            }
        }
    }
    
    return array;
}

@end
