//
//  Mission.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Mission.h"
#import "UICommon.h"

#define CURL                    @"/index/findIndexTrends.hz"
#define PUBLISH_MISSION_URL     @"/task/createTaskApp.hz"
#define PUBLISH_SHARE_URL     @"/task/createTask.hz"
#define PERSION_INFO            @"/user/findWgPeopleTrends.hz"
#define DETAIL_URL              @"/task/findTaskDetail.hz"
#define TERM_URL                @"/index/findIndexTrendsByTerm.hz"
#define REMOVE_URL              @"/task/deleteTask.hz"
#define INFO_URL                @"/task/intoUpdateTaskMian.hz"
#define UPDATE_URL              @"/task/updateTaskMian.hz"
#define FIND_WGPEOPLE_TRENDS_URL  @"/user/findWgPeopleTrends.hz"
#define UPDATE_TASK_STATUS_URL  @"/task/updateTaskStatus.hz"
#define FIND_TASK_LIST_URL   @"/task/findTaskList.hz"
#define CreateWorkPlan_URL          @"/task/createWorkPlan.hz"
#define FindWorkPlanDetailTx_URL    @"/task/findWorkPlanDetailTx.hz"
#define IntoUpdateWorkPlan_URL      @"/task/intoUpdateWorkPlan.hz"
#define UpdateWorkPlan_URL          @"/task/updateWorkPlan.hz"


@class LoginUser;

@implementation Mission

+ (NSDictionary*)getMssionListbyUserID:(NSString*)userId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount workGroupId:(NSString *)wgId termString:(NSString*)termStr keyString:(NSString *)keyStr
{
    NSDictionary* dict = [NSDictionary dictionary];

//    NSMutableArray* array = [NSMutableArray array];

    NSString* url_s;
    
//    if (![termStr isEqualToString:@""]) {
        url_s = [NSString stringWithFormat:@"%@?userId=%@&page=%ld&pageSize=%ld&workGroupId=%@&str=%@&keyString=%@",TERM_URL,userId,page,rowCount,wgId,termStr, keyStr];
//    }
//    else
//        url_s = [NSString stringWithFormat:@"%@?userId=%@&page=%ld&pageSize=%ld&workGroupId=%@",CURL,userId,page,rowCount,wgId];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:url_s];
    
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

                     NSInteger totalPages = 0;
                     if ([dataDic valueForKey:@"totalPages"] != nil) {
                         totalPages = [[dataDic valueForKey:@"totalPages"] integerValue];
                     }
                     
                 }
                
                NSLog(@"Dic:%@",dic);
            }
        }
        
    }
    
    return dict;
}

+ (BOOL)updateTaskStatus:(NSString*)taskId status:(NSInteger )status
{
    BOOL isOK = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:taskId forKey:@"taskId"];
    [dic setObject:[NSNumber numberWithInteger:status] forKey:@"status"];
    [dic setObject:[LoginUser loginUserID] forKey:@"userId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_TASK_STATUS_URL postData:dic];
    
    if (responseString == nil) {
        return isOK;
    }

    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        if ([[((NSDictionary*)val) valueForKey:@"state"] integerValue] == 1) {
            
            isOK = YES;
        }
    }
    
    return isOK;
}

+ (NSArray *)findTaskList:(NSString*)taskId mainMissionDic:(NSMutableDictionary **)mainMissionDic
{
    NSMutableDictionary * mainMDic = [NSMutableDictionary dictionary];
    NSMutableArray * childArr = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?taskId=%@",FIND_TASK_LIST_URL,taskId ]];
    
    if (responseString == nil) {
        return nil;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    Mission * ms = [Mission new];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                id dataArr = [dic objectForKey:@"data"];

                if ([dataArr isKindOfClass:[NSArray class]])
                {
                    NSArray* dArr = (NSArray*)dataArr;
                    
                    for (id data in dArr) {
                        if ([data isKindOfClass:[NSDictionary class]]) {
                            
                            NSDictionary* di = (NSDictionary*)data;
                            ms.taskId = [di valueForKey:@"taskId"];
                            ms.parentId = [di valueForKey:@"parentId"];
                            ms.title = [di valueForKey:@"title"];
                            ms.lableUserName = [di valueForKey:@"lableUserName"];
                            ms.lableUserImg = [di valueForKey:@"lableUserImg"];
                            
                            NSMutableDictionary * mDic = [NSMutableDictionary dictionary];
                            NSMutableDictionary * curDic = [NSMutableDictionary dictionary];
                            
                            [curDic setObject:ms.title forKey:@"title"];
                            [curDic setObject:ms.taskId forKey:@"taskId"];
                            [curDic setObject:ms.parentId forKey:@"parentId"];
                            [curDic setObject:ms.lableUserName forKey:@"lableUserName"];
                            [curDic setObject:ms.lableUserImg forKey:@"lableUserImg"];
                            
                            if(ms.parentId == 0)
                            {
                                [mainMDic setObject:ms.title forKey:@"title"];
                                
                                [mainMDic setObject:curDic forKey:@"missionDic"];
                                
                            }
                            else
                            {
                                [mDic setObject:ms.title forKey:@"title"];

                                [mDic setObject:curDic forKey:@"missionDic"];
                                
                                [childArr addObject:mDic];
                            }

                        }
                    }
                }

            }
        }
    }
    
    *mainMissionDic = mainMDic;
    
    return childArr;
}

+ (BOOL)findWgPeopleTrends:(NSString*)createUserId workGroupId:(NSString *)groupId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount dataListArr:(NSMutableArray **)dataListArr member:(Member **)member
{
    BOOL isOk = NO;
    
    NSMutableArray* array = [NSMutableArray array];
    
    NSString* url_s = [NSString stringWithFormat:@"%@?createUserId=%@&workGroupId=%@&userId=%@&page=%ld&pageSize=%ld",FIND_WGPEOPLE_TRENDS_URL,createUserId, groupId, [LoginUser loginUserID],page,rowCount];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:url_s];
    
    if (responseString == nil) {
        return array;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    Member * user = [Member new];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                isOk = YES;
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    NSInteger totalPages = 0;
                    if ([dataDic valueForKey:@"totalPages"] != nil) {
                        totalPages = [[dataDic valueForKey:@"totalPages"] integerValue];
                    }
                    
                    NSDictionary * userDic = [dataDic objectForKey:@"userMap"];
                    
                    
                    user.duty = [userDic valueForKey:@"duty"];
                    user.img = [userDic valueForKey:@"img"];
                    user.name = [userDic valueForKey:@"name"];
                    user.userId = [userDic valueForKey:@"userId"];
                    user.mobile = [userDic valueForKey:@"mobile"];
                    user.email = [userDic valueForKey:@"email"];
                    
                    id dataArr = [dataDic valueForKey:@"datalist"];
                    if ([dataArr isKindOfClass:[NSArray class]])
                    {
                        NSArray* dArr = (NSArray*)dataArr;
                        
                        for (id data in dArr) {
                            if ([data isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary* di = (NSDictionary*)data;
                                
                                Mission* cm = [Mission new];
                                
                                cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                                cm.hour = [di valueForKey:@"hourStr"];
                                cm.planExecTime = [di valueForKey:@"planExecTime"];
                                cm.type = [[di valueForKey:@"type"] integerValue];
                                cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                                cm.finishTime = [di valueForKey:@"finishTime"];
                                cm.createUserId = [di valueForKey:@"createUserId"];
                                cm.taskId = [di valueForKey:@"taskId"];
                                cm.workGroupId = [di valueForKey:@"workGroupId"];
                                cm.workGroupName = [di valueForKey:@"wgName"];
                                cm.main = [di valueForKey:@"main"];
                                cm.title = [di valueForKey:@"title"];
                                cm.userImg = [di valueForKey:@"userImg"];
                                cm.status = [[di valueForKey:@"status"] integerValue];
                                cm.userName = [di valueForKey:@"userName"];
                                cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                                cm.totalPages = totalPages;
                                cm.isRead = [[di valueForKey:@"isRead"] boolValue];
                                cm.isNewCom = [[di valueForKey:@"isNewCom"] boolValue];
                                cm.accessoryNum = [[di valueForKey:@"accessoryNum"] intValue];
                                cm.replayNum = [[di valueForKey:@"replayNum"] intValue];
                                cm.labelList = [di objectForKey:@"labelList"];
                                
                                [array addObject:cm];
                                
                            }
                        }
                        
                    }
                }
                
                NSLog(@"Dic:%@",dic);
            }
        }
        
    }
    
    *dataListArr = array;
    *member = user;
    
    return isOk;
    
}


+ (NSMutableArray*)getMssionListbyWorkGroupID:(NSString*)groupId andUserId:(NSString *)userId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount
{

    NSMutableArray* array = [NSMutableArray array];
    
    NSString* url_s = [NSString stringWithFormat:@"%@?workGroupId=%@&createUserId=%@&userId=%@&page=%ld&pageSize=%ld",PERSION_INFO,groupId, userId,[LoginUser loginUserID],page,rowCount];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:url_s];
    
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
                                
                                Mission* cm = [Mission new];
                                
                                cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                                cm.hour = [di valueForKey:@"hourStr"];
                                cm.planExecTime = [di valueForKey:@"planExecTime"];
                                cm.type = [[di valueForKey:@"type"] integerValue];
                                cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                                cm.finishTime = [di valueForKey:@"finishTimeStr"];
                                cm.remindTime = [di valueForKey:@"remindTimeStr"];
                                cm.createUserId = [di valueForKey:@"createUserId"];
                                cm.taskId = [di valueForKey:@"taskId"];
                                cm.workGroupId = [di valueForKey:@"workGroupId"];
                                cm.workGroupName = [di valueForKey:@"wgName"];
                                cm.main = [di valueForKey:@"main"];
                                cm.title = [di valueForKey:@"title"];
                                cm.userImg = [di valueForKey:@"userImg"];
                                cm.status = [[di valueForKey:@"status"] integerValue];
                                cm.userName = [di valueForKey:@"userName"];
                                cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                                cm.totalPages = totalPages;
                                cm.lableUserName = [di valueForKey:@"lableUserName"];
                                cm.childTaskList = [di objectForKey:@"childTaskList"];
                                cm.childNum = [[di valueForKey:@"childNum"] intValue];
                                [array addObject:cm];
                                cm.type = [[di valueForKey:@"type"] integerValue];
                                cm.parentId = [di valueForKey:@"parentId"];
                                cm.isRead = [[di valueForKey:@"isRead"] boolValue];
                                
                            }
                        }
                        
                    }
                }
                
                NSLog(@"Dic:%@",dic);
            }
        }
        
    }
    
    return array;
    
}

+ (BOOL)sendAllMission:(BOOL)isMission taksId:(NSString **)taskId withArr:(NSArray *)missionArr
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    [dic setObject:missionArr forKey:@"list"];
    
    NSString* jsonStr = [CommonFile toJson:dic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString;
    
    responseString = [HttpBaseFile requestDataWithSyncByPost:PUBLISH_MISSION_URL postData:tmpDic];
    
//    if (taskId.length)
//    {
////        responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_URL postData:tmpDic];
//        responseString = nil;//修改
//    }
//    else
//    {
//        responseString = [HttpBaseFile requestDataWithSyncByPost:PUBLISH_ALL_MISSION_URL postData:tmpDic];
//
//    }
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * taStr = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        if ([[((NSDictionary*)val) valueForKey:@"state"] integerValue] == 1) {
            
            taStr = [((NSDictionary*)val) valueForKey:@"data"];
            
            isOk = YES;
        }
    }
    
    *taskId = taStr;
    
    return isOk;
}

- (BOOL)sendMissionFromWorkPlan:(BOOL)isMission taksId:(NSString **)taskId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:self.createUserId forKey:@"userId"];
    
    if (self.taskId != nil) {
        [dic setObject:self.taskId forKey:@"taskId"];
    }
    
    [dic setObject:self.workGroupId forKey:@"workGroupId"];
    if(self.main.length)
    {
        [dic setObject:self.main forKey:@"main"];
    }
    [dic setObject:self.title forKey:@"title"];
    
    if (isMission) {
        [dic setObject:self.liableUserId forKey:@"lableUserId"];
        if(self.partList != nil)
            [dic setObject:self.partList forKey:@"partList"];
        if(self.cclist != nil)
            [dic setObject:self.cclist forKey:@"ccList"];
        
        if(self.finishTime.length)
        {
            [dic setObject:self.finishTime forKey:@"finishTime"];
        }
        
        if(self.remindTime != nil)
            [dic setObject:self.remindTime forKey:@"remindTime"];
    }
    
    [dic setObject:[NSString stringWithFormat:@"%d",self.isLabel?1:0] forKey:@"isLabel"];

    if(_cclist.count > 0)
    {
        [dic setObject:self.cclist forKey:@"ccList"];
    }
    
    if (self.isLabel)
        [dic setObject:self.labelList forKey:@"labelList"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.isAccessory?1:0]  forKey:@"isAccessory"];
    if (self.isAccessory) {
        //[dic setObject:self.accessoryList forKey:@"accessoryList"];
        NSMutableArray* tA = [NSMutableArray array];
        for (int i = 0; i < self.accessoryList.count; i++) {
            NSMutableDictionary* di = [NSMutableDictionary dictionary];
            
            Accessory* acc = [self.accessoryList objectAtIndex:i];
            
            [di setObject:acc.name forKey:@"name"];
            [di setObject:acc.address forKey:@"address"];
            [di setObject:[NSString stringWithFormat:@"%ld",acc.source] forKey:@"source"];
            //            [di setObject:acc.size forKey:@"size"];
            [tA addObject:di];
        }
        [dic setObject:tA forKey:@"accessoryList"];
    }
    [dic setObject:[NSString stringWithFormat:@"%ld",self.type] forKey:@"type"];
    
    if(!self.taskId)
    {
        [dic setObject:@"2" forKey:@"platform"];//来源平台：1：web  2：IOs  3：android  4:微信
    }
    
    NSString* jsonStr = [CommonFile toJson:dic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString;
    
    responseString = [HttpBaseFile requestDataWithSyncByPost:PUBLISH_SHARE_URL postData:tmpDic];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * taStr = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        if ([[((NSDictionary*)val) valueForKey:@"state"] integerValue] == 1) {
            
            taStr = [((NSDictionary*)val) valueForKey:@"data"];
            
            isOk = YES;
        }
    }
    
    *taskId = taStr;
    
    return isOk;
}

- (BOOL)sendMission:(BOOL)isMission taksId:(NSString **)taskId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:self.createUserId forKey:@"userId"];
    
    if (self.taskId != nil) {
        [dic setObject:self.taskId forKey:@"taskId"];
    }
    
    [dic setObject:self.workGroupId forKey:@"workGroupId"];
    [dic setObject:self.main forKey:@"main"];
    [dic setObject:self.title forKey:@"title"];

    if (isMission) {
        [dic setObject:self.liableUserId forKey:@"lableUserId"];
        if(self.partList != nil)
            [dic setObject:self.partList forKey:@"partList"];
        if(self.cclist != nil)
            [dic setObject:self.cclist forKey:@"ccList"];
        
        if(self.finishTime.length)
        {
            [dic setObject:self.finishTime forKey:@"finishTime"];
        }
        
        if(self.remindTime != nil)
            [dic setObject:self.remindTime forKey:@"remindTime"];
    }
    
    [dic setObject:[NSString stringWithFormat:@"%d",self.isLabel?1:0] forKey:@"isLabel"];
//    if(_partList.count)
//    {
//        [dic setObject:self.partList forKey:@"partList"];
//    }
    if(_cclist.count > 0)
    {
        [dic setObject:self.cclist forKey:@"ccList"];
    }
    
    if (self.isLabel)
        [dic setObject:self.labelList forKey:@"labelList"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.isAccessory?1:0]  forKey:@"isAccessory"];
    if (self.isAccessory) {
         //[dic setObject:self.accessoryList forKey:@"accessoryList"];
        NSMutableArray* tA = [NSMutableArray array];
        for (int i = 0; i < self.accessoryList.count; i++) {
            NSMutableDictionary* di = [NSMutableDictionary dictionary];
            
            Accessory* acc = [self.accessoryList objectAtIndex:i];
            
            [di setObject:acc.name forKey:@"name"];
            [di setObject:acc.address forKey:@"address"];
            [di setObject:[NSString stringWithFormat:@"%ld",acc.source] forKey:@"source"];
//            [di setObject:acc.size forKey:@"size"];
            [tA addObject:di];
        }
        [dic setObject:tA forKey:@"accessoryList"];
    }
    [dic setObject:[NSString stringWithFormat:@"%ld",self.type] forKey:@"type"];
    
    if(!self.taskId)
    {
        [dic setObject:@"2" forKey:@"platform"];//来源平台：1：web  2：IOs  3：android  4:微信
    }
    
    NSString* jsonStr = [CommonFile toJson:dic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString;
    
    if (self.taskId != nil)
    {
        responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_URL postData:tmpDic];
    }
    else
    {
        if(self.type == 1)
        {
            responseString = [HttpBaseFile requestDataWithSyncByPost:PUBLISH_MISSION_URL postData:tmpDic];
        }
        else
        {
            responseString = [HttpBaseFile requestDataWithSyncByPost:PUBLISH_SHARE_URL postData:tmpDic];
        }
    }
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * taStr = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        if ([[((NSDictionary*)val) valueForKey:@"state"] integerValue] == 1) {
            
            taStr = [((NSDictionary*)val) valueForKey:@"data"];
            
            isOk = YES;
        }
    }
    
    *taskId = taStr;
    
    return isOk;
}

+ (Mission*)detail:(NSString*)taskId commentArray:(NSArray**)comments imgArr:(NSArray **)imgArr messageId:(NSString *)messageId
{
    Mission* cm = [Mission new];
    
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray * imageArr = [NSMutableArray array];
    
    NSString * url = @"";
    if(messageId.length)
    {
        url = [NSString stringWithFormat:@"%@?taskId=%@&userId=%@&messageId=%@",DETAIL_URL,taskId,[LoginUser loginUserID], messageId];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?taskId=%@&userId=%@",DETAIL_URL,taskId,[LoginUser loginUserID]];
    }
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:url];
    
    if (responseString == nil) {
        return nil;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    
                    id tDic = [dataDic valueForKey:@"task"];
                    if ( [tDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)tDic;
                        
                        cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                        cm.hour = [di valueForKey:@"hourStr"];
                        cm.planExecTime = [di valueForKey:@"planExecTime"];
                        cm.type = [[di valueForKey:@"type"] integerValue];
                        cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                        cm.finishTime = [di valueForKey:@"finishTimeStr"];
                        cm.remindTime = [di valueForKey:@"remindTimeStr"];
                        cm.createTime = [di valueForKey:@"createTimeStr"];
                        cm.createUserId = [di valueForKey:@"createUserId"];
                        cm.taskId = [di valueForKey:@"taskId"];
                        cm.workGroupId = [di valueForKey:@"workGroupId"];
                        cm.workGroupName = [di valueForKey:@"wgName"];
                        cm.main = [di valueForKey:@"main"];
                        cm.title = [di valueForKey:@"title"];
                        cm.userImg = [di valueForKey:@"userImg"];
                        cm.status = [[di valueForKey:@"status"] integerValue];
                        cm.userName = [di valueForKey:@"userName"];
                        cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                        cm.lableUserName = [di valueForKey:@"lableUserName"];
                        cm.liableUserId = [di valueForKey:@"lableUserId"];
                        cm.parentId = [di valueForKey:@"parentId"];
                    }
                }
                cm.partList = [dataDic objectForKey:@"peopleList"];
                cm.childTaskList = [dataDic objectForKey:@"childTaskList"];
                cm.isInstructions = [[dataDic valueForKey:@"isInstructions"] boolValue];
                
                cm.labelList = [dataDic objectForKey:@"labelList"];
                
                if (cm.isAccessory) {
                    
                    id accArr = [dataDic valueForKey:@"accessoryList"];
                    
                    if ([accArr isKindOfClass:[NSArray class]])
                    {
                        NSMutableArray* accessoryArray = [NSMutableArray array];
                        
                        NSMutableArray * wordArr = [NSMutableArray array];
                        NSMutableArray * excelArr = [NSMutableArray array];
                        NSMutableArray * pptArr = [NSMutableArray array];
                        NSMutableArray * pdfArr = [NSMutableArray array];
                        NSMutableArray * otherArr = [NSMutableArray array];

                        NSArray* aArr = (NSArray*)accArr;
                        
                        for (id obj in aArr) {
                            
                            if ( [obj isKindOfClass:[NSDictionary class]]) {
                                NSDictionary* di = (NSDictionary*)obj;
                                
                                Accessory *acc = [Accessory new];
                                
                                acc.source = [[di valueForKey:@"source"] integerValue];
                                acc.isComplete = [[di valueForKey:@"isComplete"] boolValue];
                                acc.status = [[di valueForKey:@"status"] boolValue];
                                acc.address = [di valueForKey:@"address"];
                                acc.allUrl = [di valueForKey:@"allUrl"];
                                acc.originFileName = [di valueForKey:@"allName"];
                                acc.originImageSize = [di valueForKey:@"allSize"];
                                acc.name = [di valueForKey:@"name"];
                                acc.accessoryId = [di valueForKey:@"accessoryId"];
                                acc.type = [[di valueForKey:@"type"] integerValue];
                                acc.sourceId = [di valueForKey:@"sourceId"];
                                acc.addTime = [di valueForKey:@"addTime"];
                                
                                NSRange range = [acc.name rangeOfString:@"." options:NSBackwardsSearch];
                                //现获取要截取的字符串位置
                                //mask常用选项列表
                                //NSCaseInsensitiveSearch   不区分字母大小写
                                //NSLiteralSearch           对字符串进行字节单位的比较，一般可提高检索速度
                                //NSBackwardsSearch         从范围的末尾开始检索
                                //NSAnchoredSearch          仅检索制定范围的前部。忽略字符串中间的检索字符
                                NSString * fileType = [acc.name substringFromIndex:range.location + 1];
                                NSString * fileNum = @"";
                               
                                if([fileType equalsIgnoreCase:@"doc"] || [fileType equalsIgnoreCase:@"docx"])
                                {
                                    fileNum = @"1";
                                    
                                    [wordArr addObject:acc];
                                }
                                else if ([fileType equalsIgnoreCase:@"xls"] || [fileType equalsIgnoreCase:@"xlsx"])
                                {
                                    fileNum = @"2";
                                    [excelArr addObject:acc];
                                }
                                else if ([fileType equalsIgnoreCase:@"ppt"] || [fileType equalsIgnoreCase:@"pptx"])
                                {
                                    fileNum = @"3";
                                    [pptArr addObject:acc];
                                }
                                else if ([fileType equalsIgnoreCase:@"pdf"])
                                {
                                    fileNum = @"4";
                                    [pdfArr addObject:acc];
                                }
                                else if ([fileType equalsIgnoreCase:@"png"] || [fileType equalsIgnoreCase:@"jpg"] || [fileType equalsIgnoreCase:@"jpeg"])
                                {
                                    fileNum = @"5";
                                    [imageArr addObject:acc];
                                }
                                else
                                {
                                    fileNum = @"6";
                                    [otherArr addObject:acc];
                                    
                                }
                                acc.fileType = fileNum;
                                
//                                [accessoryArray addObject:acc];
                            }
                            
                        }
                        
//                        NSMutableArray * fileArr = [NSMutableArray array];
                        
                        [accessoryArray addObjectsFromArray:wordArr];
                        [accessoryArray addObjectsFromArray:excelArr];
                        [accessoryArray addObjectsFromArray:pptArr];
                        [accessoryArray addObjectsFromArray:pdfArr];
                        [accessoryArray addObjectsFromArray:otherArr];
                        [accessoryArray addObjectsFromArray:imageArr];
                        
                        cm.accessoryList = [NSArray arrayWithArray:accessoryArray];
                        
                    }
                    
                }
                
                id comArr = [dataDic valueForKey:@"list"];
                
                if ([comArr isKindOfClass:[NSArray class]])
                {
                    
                    NSArray* aArr = (NSArray*)comArr;
                    
                    for (id obj in aArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* di = (NSDictionary*)obj;
                            
                            Comment *acc = [Comment new];
                            
                            /*
                             "taskId": 1015072215290001,
                             "platform": 0,
                             "parentId": 0,
                             "createTime": "Jul 23, 2015 6:39:33 AM",
                             "level": 2,
                             "hourStr": "06:39",
                             "status": 0,
                             "userId": 1015042309240001,
                             "userName": "",
                             "commentsId": 48,
                             "userImg": "http://www.iclip365.com:8080/clip_basic/static/images/default_head.png",
                             "main": "喜欢看不会后悔"
                             */
                            
                            acc.taskId = [di valueForKey:@"taskId"];
                            acc.parentId = [di valueForKey:@"parentId"];
                            acc.parentName = [di valueForKey:@"parentName"];
                            acc.createTime = [di valueForKey:@"createTimeStr"];
                            acc.level = [[di valueForKey:@"level"] integerValue];
                            acc.praiseNum = [[di valueForKey:@"upNum"] integerValue];
                            acc.isPraised = ([[di valueForKey:@"isup"] integerValue] > 0 ? YES : NO);
                            acc.hourStr = [di valueForKey:@"hourStr"];
                            acc.userId = [di valueForKey:@"userId"];
                            acc.userName = [di valueForKey:@"userName"];
                            acc.commentsId = [di valueForKey:@"commentsId"];
                            acc.userImg = [di valueForKey:@"userImg"];
                            acc.main = [di valueForKey:@"main"];
                            acc.hasChild = [[di valueForKey:@"havaChild"] boolValue];
                            
                            NSArray * accArr = [di objectForKey:@"accessoryList"];
                            
                            NSMutableArray * accessoryArr = [NSMutableArray array];
                            
                            for(NSDictionary * dic in accArr)
                            {
                                Accessory * acce = [Accessory new];
                               
                                acce.accessoryId = [dic valueForKey:@"accessoryId"];
                                acce.address = [dic valueForKey:@"address"];
                                acce.name = [dic valueForKey:@"name"];
                                acce.originImageSize = [dic valueForKey:@"allSize"];
                                acce.allUrl = [dic valueForKey:@"allUrl"];
                                
                                [accessoryArr addObject:acce];
                            }
                            acc.accessoryList = accessoryArr;
                            
                            if (acc.hasChild) {
                                
                                id childs = [di valueForKey:@"childList"];
                                if ([childs isKindOfClass:[NSArray class]])
                                {
                                    NSArray* childArray = (NSArray*)childs;
                                    NSMutableArray* tmpArr = [NSMutableArray array];
                                    
                                    for (NSDictionary* childDic in childArray) {
                                        
                                        Comment* childComment = [Comment new];
                                        
                                        childComment.taskId = [childDic valueForKey:@"taskId"];
                                        childComment.parentId = [childDic valueForKey:@"parentId"];
                                        childComment.parentName = [childDic valueForKey:@"parentName"];
                                        childComment.createTime = [childDic valueForKey:@"createTime"];
                                        childComment.praiseNum = [[di valueForKey:@"upNum"] integerValue];
                                        childComment.isPraised = ([[di valueForKey:@"isup"] integerValue] > 0 ? YES : NO);
                                        childComment.level = [[childDic valueForKey:@"level"] integerValue];
                                        childComment.hourStr = [childDic valueForKey:@"hourStr"];
                                        childComment.userId = [childDic valueForKey:@"userId"];
                                        childComment.userName = [childDic valueForKey:@"userName"];
                                        childComment.commentsId = [childDic valueForKey:@"commentsId"];
                                        childComment.userImg = [childDic valueForKey:@"userImg"];
                                        childComment.main = [childDic valueForKey:@"main"];
                                        
                                        
                                        [tmpArr addObject:childComment];
                                    }
                                    
                                    acc.comments = [NSArray arrayWithArray:tmpArr];
                                }
                                
                            }
                            
                            [array addObject:acc];
                        }
                        
                    }
                }
                
                NSLog(@"Dic:%@",dic);
            }
            else
            {
                cm = nil;
            }
        }
        
    }
    
    *imgArr = imageArr;
    
    *comments = array;
    
    return cm;
}

+ (BOOL)reomveMission:(NSString*)taskId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:taskId forKey:@"taskId"];

    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:REMOVE_URL postData:dic];
    
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

+ (NSDictionary*)missionInfo:(NSString*)taskId
{
    NSMutableArray* resposibleArr = [NSMutableArray array];
    NSMutableArray* participantArr = [NSMutableArray array];
    NSMutableArray* copyToArr = [NSMutableArray array];
    NSMutableArray* labelArr = [NSMutableArray array];
    NSMutableArray* accessoryArr = [NSMutableArray array];
    
    Mission* cm = [Mission new];

    NSMutableDictionary * mDic = [NSMutableDictionary dictionary];
    NSMutableDictionary * curDic = [NSMutableDictionary dictionary];

    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?taskId=%@&userId=%@",INFO_URL,taskId,[LoginUser loginUserID]]];
    
    if (responseString == nil) {
        return nil;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    id tDic = [dataDic valueForKey:@"task"];
                    if ( [tDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)tDic;
                        
                        cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                        cm.hour = [di valueForKey:@"hourStr"];
                        cm.planExecTime = [di valueForKey:@"planExecTime"];
                        cm.type = [[di valueForKey:@"type"] integerValue];
                        cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                        cm.finishTime = [di valueForKey:@"finishTimeStr"];
                        cm.remindTime = [di valueForKey:@"remindTimeStr"];
                        cm.createUserId = [di valueForKey:@"createUserId"];
                        cm.taskId = [di valueForKey:@"taskId"];
                        cm.workGroupId = [di valueForKey:@"workGroupId"];
                        cm.workGroupName = [di valueForKey:@"wgName"];
                        cm.main = [di valueForKey:@"main"];
                        cm.userImg = [di valueForKey:@"userImg"];
                        cm.status = [[di valueForKey:@"status"] integerValue];
                        cm.userName = [di valueForKey:@"userName"];
                        cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                        cm.title = [di valueForKey:@"title"];
                        cm.parentId = [di valueForKey:@"parentId"];
                        
                    }
                }
                
                [mDic setObject:cm.title forKey:@"title"];
                
                if(cm.main.length)
                {
                    [curDic setObject:cm.main forKey:@"main"];
                }
                if(cm.finishTime.length)
                {
                    [curDic setObject:cm.finishTime forKey:@"finishTime"];
                }
                
                if(cm.remindTime.length)
                {
                    [curDic setObject:cm.remindTime forKey:@"remindTime"];
                }
                [curDic setObject:cm.title forKey:@"title"];
                [curDic setObject:cm.taskId forKey:@"taskId"];
                [curDic setObject:cm.parentId forKey:@"parentId"];
                [curDic setObject:cm.workGroupId forKey:@"workGroupId"];
                [curDic setObject:cm.workGroupName forKey:@"workGroupName"];

                [mDic setObject:curDic forKey:@"missionDic"];
                
            if (cm.isAccessory) {
                
                id accArr = [dataDic valueForKey:@"accessList"];
                
                if ([accArr isKindOfClass:[NSArray class]])
                {
                    
                    NSArray* aArr = (NSArray*)accArr;
                    
                    for (id obj in aArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* di = (NSDictionary*)obj;
                            
                            Accessory *acc = [Accessory new];
                            
                            acc.source = [[di valueForKey:@"source"] integerValue];
                            acc.isComplete = [[di valueForKey:@"isComplete"] boolValue];
                            acc.status = [[di valueForKey:@"status"] boolValue];
                            acc.address = [di valueForKey:@"address"];
                            acc.name = [di valueForKey:@"name"];
                            acc.accessoryId = [di valueForKey:@"accessoryId"];
                            acc.type = [[UICommon findFileType:acc.name] integerValue];
                            acc.sourceId = [di valueForKey:@"sourceId"];
                            acc.addTime = [di valueForKey:@"addTime"];
                            
                            [accessoryArr addObject:acc];
                        }
                        
                    }
                    
                }
                
            }
                
                [curDic setObject:accessoryArr forKey:@"accesList"];

            id resArr = [dataDic valueForKey:@"liableUser"];
            
            if ([resArr isKindOfClass:[NSDictionary class]])
            {
                
                NSDictionary* di = (NSDictionary*)resArr;
                
                Member *acc = [Member new];
                
                acc.userId = [di valueForKey:@"userId"];
                acc.name = [di valueForKey:@"name"];
                acc.createTime = [di valueForKey:@"createTime"];
                
                [resposibleArr addObject:acc];
                
            }
                
                [curDic setObject:resposibleArr forKey:@"respoDic"];
            
            id comArr = [dataDic valueForKey:@"ccList"];

            if ([comArr isKindOfClass:[NSArray class]])
            {
                
                NSArray* aArr = (NSArray*)comArr;
                
                for (id obj in aArr) {
                    
                    if ( [obj isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)obj;
                        
                        Member *acc = [Member new];
                        
                        acc.userId = [di valueForKey:@"userId"];
                        acc.name = [di valueForKey:@"name"];
                        acc.createTime = [di valueForKey:@"createTime"];
                        
                        [copyToArr addObject:acc];
                    }
                    
                }
            }
                [curDic setObject:copyToArr forKey:@"ccopyArr"];
            
            id parAa = [dataDic valueForKey:@"partList"];
            
            if ([parAa isKindOfClass:[NSArray class]])
            {
                
                NSArray* aArr = (NSArray*)parAa;
                
                for (id obj in aArr) {
                    
                    if ( [obj isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)obj;
                        
                        Member *acc = [Member new];
                        
                        acc.userId = [di valueForKey:@"userId"];
                        acc.name = [di valueForKey:@"name"];
                        acc.createTime = [di valueForKey:@"createTime"];
                        
                        [participantArr addObject:acc];
                    }
                    
                }
            }
                [curDic setObject:participantArr forKey:@"partiArr"];
            
            id lblArr = [dataDic valueForKey:@"taskLabelList"];
            
            if ([lblArr isKindOfClass:[NSArray class]])
            {
                NSArray* aArr = (NSArray*)lblArr;
                
                for (id obj in aArr) {
                    
                    if ( [obj isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)obj;
                        
                        Mark *acc = [Mark new];
                        
                        acc.labelId = [di valueForKey:@"labelId"];
                        acc.labelName = [di valueForKey:@"labelName"];
                        
                        [labelArr addObject:acc];
                    }
                    
                }
            }
                [curDic setObject:labelArr forKey:@"cMarkList"];
            }
        }
    }
    
    return mDic;
}


+ (Mission*)missionInfo:(NSString*)taskId responsible:(NSArray**)responsibleArray participants:(NSArray**)participantArray copyTo:(NSArray**)copyToArray labels:(NSArray**)labelArray accessories:(NSArray**)accessoryArray;
{
    NSMutableArray* resposibleArr = [NSMutableArray array];
    NSMutableArray* participantArr = [NSMutableArray array];
    NSMutableArray* copyToArr = [NSMutableArray array];
    NSMutableArray* labelArr = [NSMutableArray array];
    NSMutableArray* accessoryArr = [NSMutableArray array];

    
    Mission* cm = [Mission new];

    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?taskId=%@&userId=%@",INFO_URL,taskId,[LoginUser loginUserID]]];
    
    if (responseString == nil) {
        return nil;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    
                    id tDic = [dataDic valueForKey:@"task"];
                    if ( [tDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)tDic;
                        
                        cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                        cm.hour = [di valueForKey:@"hourStr"];
                        cm.planExecTime = [di valueForKey:@"planExecTime"];
                        cm.type = [[di valueForKey:@"type"] integerValue];
                        cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                        cm.finishTime = [di valueForKey:@"finishTimeStr"];
                        cm.remindTime = [di valueForKey:@"remindTimeStr"];
                        cm.createUserId = [di valueForKey:@"createUserId"];
                        cm.taskId = [di valueForKey:@"taskId"];
                        cm.workGroupId = [di valueForKey:@"workGroupId"];
                        cm.workGroupName = [di valueForKey:@"wgName"];
                        cm.main = [di valueForKey:@"main"];
                        cm.userImg = [di valueForKey:@"userImg"];
                        cm.status = [[di valueForKey:@"status"] integerValue];
                        cm.userName = [di valueForKey:@"userName"];
                        cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                        cm.title = [di valueForKey:@"title"];

                    }
                }
                
                if (cm.isAccessory) {
                    
                    id accArr = [dataDic valueForKey:@"accessList"];
                    
                    if ([accArr isKindOfClass:[NSArray class]])
                    {
                        
                        NSArray* aArr = (NSArray*)accArr;
                        
                        for (id obj in aArr) {
                            
                            if ( [obj isKindOfClass:[NSDictionary class]]) {
                                NSDictionary* di = (NSDictionary*)obj;
                                
                                Accessory *acc = [Accessory new];
                                
                                acc.source = [[di valueForKey:@"source"] integerValue];
                                acc.isComplete = [[di valueForKey:@"isComplete"] boolValue];
                                acc.status = [[di valueForKey:@"status"] boolValue];
                                acc.address = [di valueForKey:@"address"];
                                acc.name = [di valueForKey:@"name"];
                                acc.accessoryId = [di valueForKey:@"accessoryId"];
                                acc.type = [[di valueForKey:@"type"] integerValue];
                                acc.sourceId = [di valueForKey:@"sourceId"];
                                acc.addTime = [di valueForKey:@"addTime"];
                                
                                [accessoryArr addObject:acc];
                            }
                            
                        }
                        
                    }
                    
                }
                
                id resArr = [dataDic valueForKey:@"liableUser"];
                
                if ([resArr isKindOfClass:[NSDictionary class]])
                {
                    
                    NSDictionary* di = (NSDictionary*)resArr;
                    
                    Member *acc = [Member new];
                    
                    acc.userId = [di valueForKey:@"userId"];
                    acc.name = [di valueForKey:@"name"];
                    acc.createTime = [di valueForKey:@"createTime"];
                    
                    [resposibleArr addObject:acc];

                }
                
                
                id comArr = [dataDic valueForKey:@"ccList"];
                
                if ([comArr isKindOfClass:[NSArray class]])
                {
                    
                    NSArray* aArr = (NSArray*)comArr;
                    
                    for (id obj in aArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* di = (NSDictionary*)obj;
                            
                            Member *acc = [Member new];
                            
                            acc.userId = [di valueForKey:@"userId"];
                            acc.name = [di valueForKey:@"name"];
                            acc.createTime = [di valueForKey:@"createTime"];
                            
                            [copyToArr addObject:acc];
                        }
                        
                    }
                }
                
                
                id parAa = [dataDic valueForKey:@"partList"];
                
                if ([parAa isKindOfClass:[NSArray class]])
                {
                    
                    NSArray* aArr = (NSArray*)parAa;
                    
                    for (id obj in aArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* di = (NSDictionary*)obj;
                            
                            Member *acc = [Member new];
                            
                            acc.userId = [di valueForKey:@"userId"];
                            acc.name = [di valueForKey:@"name"];
                            acc.createTime = [di valueForKey:@"createTime"];
                            
                            [participantArr addObject:acc];
                        }
                        
                    }
                }
                
                
                id lblArr = [dataDic valueForKey:@"taskLabelList"];
                
                if ([lblArr isKindOfClass:[NSArray class]])
                {
                    NSArray* aArr = (NSArray*)lblArr;
                    
                    for (id obj in aArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* di = (NSDictionary*)obj;
                            
                            Mark *acc = [Mark new];
                            
                            acc.labelId = [di valueForKey:@"labelId"];
                            acc.labelName = [di valueForKey:@"labelName"];
                            
                            [labelArr addObject:acc];
                        }
                        
                    }
                }
                
                NSLog(@"Dic:%@",dic);
            }
        }
        
    }
    *responsibleArray = resposibleArr;
    *participantArray = participantArr;
    *copyToArray = copyToArr;
    *labelArray = labelArr;
    *accessoryArray = accessoryArr;
    //*comments = array;
    
    return cm;
}

+ (BOOL)updateWorkPlan:(NSString*)loginUserId taskId:(NSString *)taskId workGroupId:(NSString*)workGroupId workPlanTitle:(NSString *)workPlanTitle startTime:(NSString *)startTime finishTime:(NSString *)finishTime taskList:(NSArray*)taskList andType:(NSString *)type
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* mainDic = [NSMutableDictionary dictionary];
    
    [dic setObject:taskId forKey:@"taskId"];
    [dic setObject:loginUserId forKey:@"userId"];
    if(workGroupId)
    {
        [dic setObject:workGroupId forKey:@"workGroupId"];
    }
    [dic setObject:workPlanTitle forKey:@"title"];
    [dic setObject:@"0" forKey:@"lableUserId"];
    [dic setObject:@"0" forKey:@"isLabel"];
    [dic setObject:@"0" forKey:@"isAccessory"];
    [dic setObject:type forKey:@"type"];
    [dic setObject:@"2" forKey:@"platform"];
    [dic setObject:@"0" forKey:@"parentId"];
    
    if(finishTime.length)
    {
        [dic setObject:finishTime forKey:@"finishTime"];
    }
    [dic setObject:startTime forKey:@"startTime"];
    
    [mainDic setObject:dic forKey:@"vo"];
    [mainDic setObject:taskList forKey:@"labelList"];
    
    NSString* jsonStr = [CommonFile toJson:mainDic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UpdateWorkPlan_URL postData:tmpDic];
    
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

+ (BOOL)createWorkPlan:(NSString*)loginUserId workGroupId:(NSString*)workGroupId workPlanTitle:(NSString *)workPlanTitle startTime:(NSString *)startTime finishTime:(NSString *)finishTime taskList:(NSArray*)taskList
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* mainDic = [NSMutableDictionary dictionary];

    [dic setObject:@"0" forKey:@"taskId"];
    [dic setObject:loginUserId forKey:@"userId"];
    if(workGroupId)
    {
        [dic setObject:workGroupId forKey:@"workGroupId"];
    }
    [dic setObject:workPlanTitle forKey:@"title"];
    [dic setObject:@"0" forKey:@"lableUserId"];
    [dic setObject:@"0" forKey:@"isLabel"];
    [dic setObject:@"0" forKey:@"isAccessory"];
    [dic setObject:@"4" forKey:@"type"];
    [dic setObject:@"2" forKey:@"platform"];
    [dic setObject:@"0" forKey:@"parentId"];
    if(finishTime.length)
    {
        [dic setObject:finishTime forKey:@"finishTime"];
    }
    [dic setObject:startTime forKey:@"startTime"];

    [mainDic setObject:dic forKey:@"vo"];
    [mainDic setObject:taskList forKey:@"labelList"];
        
    NSString* jsonStr = [CommonFile toJson:mainDic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:CreateWorkPlan_URL postData:tmpDic];
    
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

+ (Mission*)findWorkPlanDetailTx:(NSString*)taskId commentArray:(NSArray**)comments finishArray:(NSArray**)finishArr unfinishArray:(NSArray **)unfinishArr
{
    Mission* cm = [Mission new];
    
    NSMutableArray* array = [NSMutableArray array];

    NSMutableArray* finishArray = [NSMutableArray array];
    NSMutableArray* unfinishArray = [NSMutableArray array];
    
    NSString * url = [NSString stringWithFormat:@"%@?taskId=%@&userId=%@",FindWorkPlanDetailTx_URL,taskId,[LoginUser loginUserID]];

    
    NSData* responseString = [HttpBaseFile requestDataWithSync:url];
    
    if (responseString == nil) {
        return nil;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    
                    id tDic = [dataDic valueForKey:@"task"];
                    if ( [tDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)tDic;
                        
                        cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                        cm.hour = [di valueForKey:@"hourStr"];
                        cm.planExecTime = [di valueForKey:@"planExecTime"];
                        cm.type = [[di valueForKey:@"type"] integerValue];
                        cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                        cm.finishTime = [di valueForKey:@"finishTimeStr"];
                        cm.remindTime = [di valueForKey:@"remindTimeStr"];
                        cm.createTime = [di valueForKey:@"createTimeStr"];
                        cm.createUserId = [di valueForKey:@"createUserId"];
                        cm.taskId = [di valueForKey:@"taskId"];
                        cm.workGroupId = [di valueForKey:@"workGroupId"];
                        cm.workGroupName = [di valueForKey:@"wgName"];
                        cm.main = [di valueForKey:@"main"];
                        cm.title = [di valueForKey:@"title"];
                        cm.userImg = [di valueForKey:@"userImg"];
                        cm.status = [[di valueForKey:@"status"] integerValue];
                        cm.userName = [di valueForKey:@"userName"];
                        cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                        cm.lableUserName = [di valueForKey:@"lableUserName"];
                        cm.liableUserId = [di valueForKey:@"lableUserId"];
                        cm.parentId = [di valueForKey:@"parentId"];
                        cm.startTime = [di valueForKey:@"startTimeStr"];//开始时间 
                    }
                }

                cm.isInstructions = [[dataDic valueForKey:@"isInstructions"] boolValue];
                
                id labelDic = [dataDic valueForKey:@"labelList"];
                
                NSMutableArray * lblArr = [NSMutableArray array];
                

                
                if([labelDic isKindOfClass:[NSArray class]])
                {
                    NSArray* alArr = (NSArray*)labelDic;
                    
                    for (id obj in alArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]])
                        {
                            NSMutableDictionary * lblDic = [NSMutableDictionary dictionaryWithDictionary:obj];

                            NSMutableDictionary * finishDic = [NSMutableDictionary dictionaryWithDictionary:obj];
                            NSMutableDictionary * unfinishDic = [NSMutableDictionary dictionaryWithDictionary:obj];

                            id labelArr = [obj valueForKey:@"taskList"];
                            
                            NSMutableArray * taskList = [NSMutableArray array];
                            
                            NSMutableArray * finishList = [NSMutableArray array];
                            NSMutableArray * unfinishList = [NSMutableArray array];

                            if([labelArr isKindOfClass:[NSArray class]])
                            {
                                NSArray* aArr = (NSArray*)labelArr;
                                
                                for (id obj in aArr) {
                                    
                                    if ( [obj isKindOfClass:[NSDictionary class]])
                                    {
                                        NSDictionary* di = (NSDictionary*)obj;
                                        
                                        Mission *mis = [Mission new];
                                        
                                        mis.taskId = [di valueForKey:@"taskId"];
                                        mis.title = [di valueForKey:@"title"];
                                        mis.status = [[di valueForKey:@"status"] integerValue];
                                        mis.reason = [di valueForKey:@"reason"];
                                        mis.finishTime = [di valueForKey:@"finishTimeStr"];
                                        mis.createUserId = [di valueForKey:@"createUserId"];
                                        mis.lableUserName = [di valueForKey:@"lableUserName"];//责任人
                                        mis.labelId = [NSNumber numberWithInteger:[[lblDic valueForKey:@"labelId" ] integerValue]];
                                        
                                        if(mis.status == 2)
                                        {
                                            [finishList addObject:mis];
                                        }
                                        else
                                        {
                                            [unfinishList addObject:mis];
                                        }
                                        
                                        [taskList addObject:mis];
                                    }
                                }
                            }
                            [lblDic removeObjectForKey:@"taskList"];
                            [lblDic setObject:taskList forKey:@"taskList"];
                            
                            if(finishList.count)
                            {
                                [finishDic removeObjectForKey:@"taskList"];
                                [finishDic setObject:finishList forKey:@"taskList"];
                                
                                [finishArray addObject:finishDic];
                            }
                            if(unfinishList.count)
                            {
                                [unfinishDic removeObjectForKey:@"taskList"];
                                [unfinishDic setObject:unfinishList forKey:@"taskList"];
                                
                                [unfinishArray addObject:unfinishDic];
                            }
                            
                            [lblArr addObject:lblDic];
                        }
                    }

                }
                
                
                cm.labelList = lblArr;
                
                id comArr = [dataDic valueForKey:@"list"];
                
                if ([comArr isKindOfClass:[NSArray class]])
                {
                    
                    NSArray* aArr = (NSArray*)comArr;
                    
                    for (id obj in aArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* di = (NSDictionary*)obj;
                            
                            Comment *acc = [Comment new];
                            
                            /*
                             "taskId": 1015072215290001,
                             "platform": 0,
                             "parentId": 0,
                             "createTime": "Jul 23, 2015 6:39:33 AM",
                             "level": 2,
                             "hourStr": "06:39",
                             "status": 0,
                             "userId": 1015042309240001,
                             "userName": "",
                             "commentsId": 48,
                             "userImg": "http://www.iclip365.com:8080/clip_basic/static/images/default_head.png",
                             "main": "喜欢看不会后悔"
                             */
                            
                            acc.taskId = [di valueForKey:@"taskId"];
                            acc.parentId = [di valueForKey:@"parentId"];
                            acc.parentName = [di valueForKey:@"parentName"];
                            acc.createTime = [di valueForKey:@"createTimeStr"];
                            acc.level = [[di valueForKey:@"level"] integerValue];
                            acc.praiseNum = [[di valueForKey:@"upNum"] integerValue];
                            acc.isPraised = ([[di valueForKey:@"isup"] integerValue] > 0 ? YES : NO);
                            acc.hourStr = [di valueForKey:@"hourStr"];
                            acc.userId = [di valueForKey:@"userId"];
                            acc.userName = [di valueForKey:@"userName"];
                            acc.commentsId = [di valueForKey:@"commentsId"];
                            acc.userImg = [di valueForKey:@"userImg"];
                            acc.main = [di valueForKey:@"main"];
                            acc.hasChild = [[di valueForKey:@"havaChild"] boolValue];
                            
                            NSArray * accArr = [di objectForKey:@"accessoryList"];
                            
                            NSMutableArray * accessoryArr = [NSMutableArray array];
                            
                            for(NSDictionary * dic in accArr)
                            {
                                Accessory * acce = [Accessory new];
                                
                                acce.accessoryId = [dic valueForKey:@"accessoryId"];
                                acce.address = [dic valueForKey:@"address"];
                                acce.name = [dic valueForKey:@"name"];
                                acce.originImageSize = [dic valueForKey:@"allSize"];
                                acce.allUrl = [dic valueForKey:@"allUrl"];
                                
                                [accessoryArr addObject:acce];
                            }
                            acc.accessoryList = accessoryArr;
                            
                            if (acc.hasChild) {
                                
                                id childs = [di valueForKey:@"childList"];
                                if ([childs isKindOfClass:[NSArray class]])
                                {
                                    NSArray* childArray = (NSArray*)childs;
                                    NSMutableArray* tmpArr = [NSMutableArray array];
                                    
                                    for (NSDictionary* childDic in childArray) {
                                        
                                        Comment* childComment = [Comment new];
                                        
                                        childComment.taskId = [childDic valueForKey:@"taskId"];
                                        childComment.parentId = [childDic valueForKey:@"parentId"];
                                        childComment.parentName = [childDic valueForKey:@"parentName"];
                                        childComment.createTime = [childDic valueForKey:@"createTime"];
                                        childComment.praiseNum = [[di valueForKey:@"upNum"] integerValue];
                                        childComment.isPraised = ([[di valueForKey:@"isup"] integerValue] > 0 ? YES : NO);
                                        childComment.level = [[childDic valueForKey:@"level"] integerValue];
                                        childComment.hourStr = [childDic valueForKey:@"hourStr"];
                                        childComment.userId = [childDic valueForKey:@"userId"];
                                        childComment.userName = [childDic valueForKey:@"userName"];
                                        childComment.commentsId = [childDic valueForKey:@"commentsId"];
                                        childComment.userImg = [childDic valueForKey:@"userImg"];
                                        childComment.main = [childDic valueForKey:@"main"];
                                        
                                        
                                        [tmpArr addObject:childComment];
                                    }
                                    
                                    acc.comments = [NSArray arrayWithArray:tmpArr];
                                }
                                
                            }
                            
                            [array addObject:acc];
                        }
                        
                    }
                }
                
                NSLog(@"Dic:%@",dic);
            }
            else
            {
                cm = nil;
            }
        }
        
    }
    
    *comments = array;
    
    *finishArr = finishArray;
    *unfinishArr = unfinishArray;
    
    return cm;
}

+ (Mission*)intoUpdateWorkPlan:(NSString*)taskId startTime:(NSString *)startTime andFinishTime:(NSString *)finishTime
{
    Mission* cm = [Mission new];
    
//    NSDate * startDate = [UICommon formatDate:startTime];
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate:startDate];
//    NSDate *localeStartDate = [startDate dateByAddingTimeInterval:interval];
//    NSLog(@"%@", localeStartDate);
//    // 时间转换成时间戳
//    NSString *timeStartSp = [NSString stringWithFormat:@"%ld",(long)[localeStartDate timeIntervalSince1970]];
//    NSLog(@"timeSp : %@", timeStartSp);
//    
//    NSDate * finishDate = [UICommon formatDate:finishTime];
//    NSInteger interval = [zone secondsFromGMTForDate:finishDate];
//    NSDate *localeStartDate = [startDate dateByAddingTimeInterval:interval];
//    NSLog(@"%@", localeStartDate);
//    // 时间转换成时间戳
//    NSString *timeStartSp = [NSString stringWithFormat:@"%ld",(long)[localeStartDate timeIntervalSince1970]];
//    NSLog(@"timeSp : %@", timeStartSp);
    
    NSString * url = [NSString stringWithFormat:@"%@?taskId=%@&userId=%@&startTimeStr=%@&endTimeStr=%@",IntoUpdateWorkPlan_URL,taskId,[LoginUser loginUserID], startTime, finishTime];
    
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:url];
    
    if (responseString == nil) {
        return nil;
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    
                    id tDic = [dataDic valueForKey:@"task"];
                    if ( [tDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* di = (NSDictionary*)tDic;
                        
                        cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                        cm.hour = [di valueForKey:@"hourStr"];
                        cm.planExecTime = [di valueForKey:@"planExecTime"];
                        cm.type = [[di valueForKey:@"type"] integerValue];
                        cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                        cm.finishTime = [di valueForKey:@"finishTimeStr"];
                        cm.remindTime = [di valueForKey:@"remindTimeStr"];
                        cm.createTime = [di valueForKey:@"createTimeStr"];
                        cm.createUserId = [di valueForKey:@"createUserId"];
                        cm.taskId = [di valueForKey:@"taskId"];
                        cm.workGroupId = [di valueForKey:@"workGroupId"];
                        cm.workGroupName = [di valueForKey:@"wgName"];
                        cm.main = [di valueForKey:@"main"];
                        cm.title = [di valueForKey:@"title"];
                        cm.userImg = [di valueForKey:@"userImg"];
                        cm.status = [[di valueForKey:@"status"] integerValue];
                        cm.userName = [di valueForKey:@"userName"];
                        cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                        cm.lableUserName = [di valueForKey:@"lableUserName"];
                        cm.liableUserId = [di valueForKey:@"lableUserId"];
                        cm.parentId = [di valueForKey:@"parentId"];
                        cm.startTime = [di valueForKey:@"startTimeStr"];//开始时间
                    }
                }
                
                cm.isInstructions = [[dataDic valueForKey:@"isInstructions"] boolValue];
                
                id labelDic = [dataDic valueForKey:@"labelList"];
                
                NSMutableArray * lblArr = [NSMutableArray array];
                
                if([labelDic isKindOfClass:[NSArray class]])
                {
                    NSArray* alArr = (NSArray*)labelDic;
                    
                    for (id obj in alArr) {
                        
                        if ( [obj isKindOfClass:[NSDictionary class]])
                        {
                            NSMutableDictionary * lblDic = [NSMutableDictionary dictionaryWithDictionary:obj];
                            
                            id labelArr = [obj valueForKey:@"taskList"];
                            
                            NSMutableArray * taskList = [NSMutableArray array];
                            
                            if([labelArr isKindOfClass:[NSArray class]])
                            {
                                NSArray* aArr = (NSArray*)labelArr;
                                
                                for (id obj in aArr) {
                                    
                                    if ( [obj isKindOfClass:[NSDictionary class]])
                                    {
                                        NSDictionary* di = (NSDictionary*)obj;
                                        
                                        Mission *mis = [Mission new];
                                        
                                        mis.taskId = [di valueForKey:@"taskId"];
                                        mis.title = [di valueForKey:@"title"];
                                        mis.status = [[di valueForKey:@"status"] integerValue];
                                        mis.finishTime = [di valueForKey:@"finishTimeStr"];
                                        mis.createUserId = [di valueForKey:@"createUserId"];
                                        mis.lableUserName = [di valueForKey:@"lableUserName"];//责任人
                                        [taskList addObject:mis];
                                    }
                                }
                            }
                            [lblDic removeObjectForKey:@"taskList"];
                            [lblDic setObject:taskList forKey:@"taskList"];
                            
                            [lblArr addObject:lblDic];
                        }
                    }
                    
                }
                
                
                cm.labelList = lblArr;
                
                NSLog(@"Dic:%@",dic);
            }
            else
            {
                cm = nil;
            }
        }
        
    }
    
    return cm;
}

@end
