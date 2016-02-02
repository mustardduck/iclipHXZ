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
#define AddWgLabelList_URL   @"/workgroup/addWgLabelList.hz"


#define DELETE_URL          @"/workgroup/deleteWgLabel.hz"
#define UPDATE_URL          @"/workgroup/updateWgLabel.hz"
#define UPDATE_MEM_URL      @"/workgroup/updateWgPeopleLabel.hz"

#define UPDATE_LABEL_MAIN_WORK_URL @"/workgroup/updateLabelMainWork.hz"

#define FindWgLabelForUpdate_URL      @"/workgroup/findWgLabelForUpdate.hz"
#define UpdateWgPeopleLabelNew_URL    @"/workgroup/updateWgPeopleLabelNew.hz"

@implementation Mark

+ (BOOL)updateLabelMainWork:(NSString *)labelId isMainLabel:(BOOL) isMainLabel
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString * status = @"1";
    if(!isMainLabel)
    {
        status = @"0";
    }
    [dic setObject:status forKey:@"type"];
    [dic setObject:labelId forKey:@"labelId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_LABEL_MAIN_WORK_URL postData:dic];
    
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

+ (BOOL) updateWgPeopleLabelNew:(NSString *)tagStr workContactsId:(NSString *)workContactsId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:tagStr forKey:@"str"];
    [dic setObject:workContactsId forKey:@"workContactsId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UpdateWgPeopleLabelNew_URL postData:dic];
    
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

+ (NSArray *) findWgLabelForUpdate:(NSString *)workGroupId workContactsId:(NSString *) workContactsId
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&workContactsId=%@",FindWgLabelForUpdate_URL, workGroupId, workContactsId]];
    
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
                            
                            Mark * m = [Mark new];
                            
                            m.labelId = [di valueForKey:@"labelId"];
                            m.labelName = [di valueForKey:@"labelName"];
                            m.isSystem = [[di valueForKey:@"level"] intValue] == 1?YES:NO;
                            m.mainLabel = [[di valueForKey:@"type"] intValue] == 1 ? YES: NO;
                            m.createName = [di valueForKey:@"createName"];
                            m.labelNum = [di valueForKey:@"labelNum"];
                            m.isHave = [[di valueForKey:@"isHave"] intValue] == 1 ? YES: NO;
                            
                            [array addObject:m];
                            
                        }
                    }
                }
            }
        }
    }
    
    return array;
}

+ (NSArray*)getMarkListByWorkGroupID:(NSString*)workGroupId loginUserID:(NSString*)userid andUrl:(NSString *)url selectArr:(NSMutableArray **)selectArr
{
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray * selArr = [NSMutableArray array];

    NSData* responseString = nil;
    
    responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&levelStr=1,2&statusStr=1",url,workGroupId]];
    
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
                            
                            Mark* cm = [Mark new];
                            
                            cm.labelId = [di valueForKey:@"labelId"];
                            cm.labelName = [di valueForKey:@"labelName"];
                            cm.isSystem = [[di valueForKey:@"level"] intValue] == 1?YES:NO;
                            cm.mainLabel = [[di valueForKey:@"type"] intValue] == 1 ? YES: NO;
                            cm.createName = [di valueForKey:@"createName"];
                            cm.labelNum = [di valueForKey:@"labelNum"];
                            
                            if(cm.mainLabel && !cm.isSystem)
                            {
                                [selArr addObject:cm];
                            }
                            
                            if(!cm.isSystem)
                            {
                                [array addObject:cm];
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    *selectArr = selArr;
    
    return array;
}

+ (NSArray*)getMarkListByWorkGroupID:(NSString*)workGroupId loginUserID:(NSString*)userid andUrl:(NSString *)url
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSData* responseString = nil;
    
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

+ (BOOL)addWgLabelList:(NSArray*)labelNameList workGroupID:(NSString*)workGroupId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:workGroupId forKey:@"workGroupId"];
    [dic setObject:labelNameList forKey:@"labelNameList"];
    
    NSString* jsonStr = [CommonFile toJson:dic];
    
    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];
    [tmpDic setObject:jsonStr forKey:@"json"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:AddWgLabelList_URL postData:tmpDic];
    
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

+ (BOOL)createNewMark:(NSString*)labelName workGroupID:(NSString*)workGroupId
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    NSString* userId = [LoginUser loginUserID];
    
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:workGroupId forKey:@"workGroupId"];
    [dic setObject:labelName forKey:@"labelName"];

    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:NEW_URL postData:dic];
    
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

+ (BOOL)remove:(NSString*)labelID workGroupId:(NSString*)wgid
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    [dic setObject:labelID forKey:@"labelId"];
    [dic setObject:@"-1" forKey:@"status"];
    [dic setObject:wgid forKey:@"workGroupId"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:DELETE_URL postData:dic];
    
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

+ (BOOL)update:(NSString*)labelID labelName:(NSString*)name
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:labelID forKey:@"labelId"];
    [dic setObject:name forKey:@"labelName"];
    
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
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_MEM_URL postData:dic];
    
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


@end
