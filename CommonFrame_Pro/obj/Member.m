//
//  Member.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Member.h"
#import "LoginUser.h"

#define CURL                @"/org/findOrgContactByInitial.hz?orgId=1015050511520001"
#define WORKGROUP_URL       @"/workgroup/findWgPeopleListByInitial.hz"
#define MEMBER_INFO_URL     @"/workgroup/findWgPeopleDetail.hz"
#define MARK_URL            @"/workgroup/findWgPeopleListByLabel.hz"
#define UPDATEWGPEOPLESTRUS_URL   @"/workgroup/updateWgPeopleStrtus.hz"

@implementation Member

+ (NSArray*)getAllMembers:(NSMutableArray**)sections searchText:(NSString*)searchString
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:(searchString == nil ? CURL : [NSString stringWithFormat:@"%@&str=%@",CURL,searchString])];
    
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
                    for (int i = 0; i < tmpSection.count; i++)
                    {
                        NSString* tmpKey = [tmpSection objectAtIndex:i];
                        id sArr = [dataDic valueForKey:tmpKey];
                        if (sArr != nil)
                        {
                            [sectionArray addObject:tmpKey];
                            
                            if ([sArr isKindOfClass:[NSArray class]])
                            {
                                NSArray* dArr = (NSArray*)sArr;
                                NSMutableArray* sectionMemberArray = [NSMutableArray array];
                                
                                for (id data in dArr) {
                                    if ([data isKindOfClass:[NSDictionary class]]) {
                                        
                                        NSDictionary* di = (NSDictionary*)data;
                                        
                                        Member* cm = [Member new];
                                        
                                        cm.orgcontactId = [di valueForKey:@"orgcontactId"];
                                        cm.orggroupId = [di valueForKey:@"orggroupId"];
                                        cm.orgId = [di valueForKey:@"orgId"];
                                        cm.userId = [di valueForKey:@"userId"];
                                        cm.name = [di valueForKey:@"name"];
                                        cm.company = [di valueForKey:@"company"];
                                        cm.address = [di valueForKey:@"address"];
                                        cm.officeTel = [di valueForKey:@"officeTel"];
                                        cm.faxTel = [di valueForKey:@"faxTel"];
                                        cm.email = [di valueForKey:@"email"];
                                        cm.duty = [di valueForKey:@"duty"];
                                        cm.remark = [di valueForKey:@"remark"];
                                        cm.img = [di valueForKey:@"img"];
                                        cm.QQ = [di valueForKey:@"QQ"];
                                        cm.version = [di valueForKey:@"version"];
                                        cm.createTime = [di valueForKey:@"createTime"];
                                        cm.status = [[di valueForKey:@"status"] boolValue];
                                        
                                        [sectionMemberArray addObject:cm];
                                    }
                                }
                                
                                [array addObject:sectionMemberArray];
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    *sections = sectionArray;
    
    return array;
}

+ (NSArray*)getAllMembersExceptMe:(NSMutableArray**)sections searchText:(NSString*)searchString
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:(searchString == nil ? CURL : [NSString stringWithFormat:@"%@&str=%@",CURL,searchString])];
    
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
                    for (int i = 0; i < tmpSection.count; i++)
                    {
                        NSString* tmpKey = [tmpSection objectAtIndex:i];
                        id sArr = [dataDic valueForKey:tmpKey];
                        if (sArr != nil)
                        {
                            [sectionArray addObject:tmpKey];

                            if ([sArr isKindOfClass:[NSArray class]])
                            {
                                NSArray* dArr = (NSArray*)sArr;
                                NSMutableArray* sectionMemberArray = [NSMutableArray array];
                                
                                for (id data in dArr) {
                                    if ([data isKindOfClass:[NSDictionary class]]) {
                                        
                                        NSDictionary* di = (NSDictionary*)data;
                                        
                                        Member* cm = [Member new];
                                        
                                        cm.orgcontactId = [di valueForKey:@"orgcontactId"];
                                        cm.orggroupId = [di valueForKey:@"orggroupId"];
                                        cm.orgId = [di valueForKey:@"orgId"];
                                        cm.userId = [di valueForKey:@"userId"];
                                        cm.name = [di valueForKey:@"name"];
                                        if(cm.userId == [LoginUser loginUserID])
                                        {
                                            [sectionArray removeObject:tmpKey];
                                            
                                            break;
                                        }
                                        cm.company = [di valueForKey:@"company"];
                                        cm.address = [di valueForKey:@"address"];
                                        cm.officeTel = [di valueForKey:@"officeTel"];
                                        cm.faxTel = [di valueForKey:@"faxTel"];
                                        cm.email = [di valueForKey:@"email"];
                                        cm.duty = [di valueForKey:@"duty"];
                                        cm.remark = [di valueForKey:@"remark"];
                                        cm.img = [di valueForKey:@"img"];
                                        cm.QQ = [di valueForKey:@"QQ"];
                                        cm.version = [di valueForKey:@"version"];
                                        cm.createTime = [di valueForKey:@"createTime"];
                                        cm.status = [[di valueForKey:@"status"] boolValue];
                                        
                                        [sectionMemberArray addObject:cm];
                                    }
                                }
                                if(sectionMemberArray.count)
                                {
                                    [array addObject:sectionMemberArray];
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    *sections = sectionArray;
    
    return array;
}

+ (NSArray*)getAllMembers:(NSMutableArray**)sections participantsArray:(NSArray*)pArray
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:CURL];
    
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
                    for (int i = 0; i < tmpSection.count; i++)
                    {
                        NSString* tmpKey = [tmpSection objectAtIndex:i];
                        id sArr = [dataDic valueForKey:tmpKey];
                        if (sArr != nil)
                        {
                            
                            if ([sArr isKindOfClass:[NSArray class]])
                            {
                                NSArray* dArr = (NSArray*)sArr;
                                NSMutableArray* sectionMemberArray = [NSMutableArray array];
                                
                                for (id data in dArr) {
                                    if ([data isKindOfClass:[NSDictionary class]]) {
                                        
                                        NSDictionary* di = (NSDictionary*)data;
                                        
                                        Member* cm = [Member new];
                                        cm.userId = [di valueForKey:@"userId"];
                                        
                                        BOOL ex = NO;
                                        for (Member* pm in pArray) {
                                            if (cm.userId == pm.userId) {
                                                ex = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (ex) {
                                            continue;
                                        }
                                        
                                        cm.orgcontactId = [di valueForKey:@"orgcontactId"];
                                        cm.orggroupId = [di valueForKey:@"orggroupId"];
                                        cm.orgId = [di valueForKey:@"orgId"];
                                        cm.name = [di valueForKey:@"name"];
                                        cm.company = [di valueForKey:@"company"];
                                        cm.address = [di valueForKey:@"address"];
                                        cm.officeTel = [di valueForKey:@"officeTel"];
                                        cm.faxTel = [di valueForKey:@"faxTel"];
                                        cm.email = [di valueForKey:@"email"];
                                        cm.duty = [di valueForKey:@"duty"];
                                        cm.remark = [di valueForKey:@"remark"];
                                        cm.img = [di valueForKey:@"img"];
                                        cm.QQ = [di valueForKey:@"QQ"];
                                        cm.version = [di valueForKey:@"version"];
                                        cm.createTime = [di valueForKey:@"createTime"];
                                        cm.status = [[di valueForKey:@"status"] boolValue];
                                        
                                        [sectionMemberArray addObject:cm];
                                    }
                                }
                                
                                [array addObject:sectionMemberArray];
                                if(sectionMemberArray.count > 0)
                                    [sectionArray addObject:tmpKey];
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    *sections = sectionArray;
    
    return array;
}

+ (NSArray*)getAllMembersByWorkGroupID:(NSMutableArray**)sections workGroupID:(NSString*)workGroupId
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    
    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@",WORKGROUP_URL,workGroupId]];
    
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
                    for (int i = 0; i < tmpSection.count; i++)
                    {
                        NSString* tmpKey = [tmpSection objectAtIndex:i];
                        id sArr = [dataDic valueForKey:tmpKey];
                        if (sArr != nil)
                        {
                            [sectionArray addObject:tmpKey];
                            
                            if ([sArr isKindOfClass:[NSArray class]])
                            {
                                NSArray* dArr = (NSArray*)sArr;
                                NSMutableArray* sectionMemberArray = [NSMutableArray array];
                                
                                for (id data in dArr) {
                                    if ([data isKindOfClass:[NSDictionary class]]) {
                                        
                                        NSDictionary* di = (NSDictionary*)data;
                                        
                                        Member* mem = [Member new];
                                        
                                        NSLog(@"%@",[di valueForKey:@"workContactsId"]);
                                        
                                        mem.workContractsId = [di valueForKey:@"workContactsId"];
                                        mem.workGroupId = [di valueForKey:@"workGroupId"];
                                        mem.isAdmin = [[di valueForKey:@"isAdmin"] boolValue];
                                        mem.userId = [di valueForKey:@"userId"];
                                        mem.name = [di valueForKey:@"name"];
                                        mem.officeTel = [di valueForKey:@"officeTel"];
                                        mem.email = [di valueForKey:@"email"];
                                        mem.duty = [di valueForKey:@"duty"];
                                        mem.img = [di valueForKey:@"img"];
                                        mem.QQ = [di valueForKey:@"QQ"];
                                        mem.createTime = [di valueForKey:@"createTime"];
                                        mem.status = [[di valueForKey:@"status"] boolValue];
                                        
                                        [sectionMemberArray addObject:mem];
                                    }
                                }
                                
                                [array addObject:sectionMemberArray];
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    *sections = sectionArray;
    
    return array;
}

+ (Member*)getMemberInfoByWorkContractsID:(NSString*)contractID
{
    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workContactsId=%@",MEMBER_INFO_URL,contractID]];
    
    if (responseString == nil) {
        return [Member new];
    }
    id val = [CommonFile json:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                
                id dataDic = [dic valueForKey:@"data"];
                
                if ([dataDic isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary* di = (NSDictionary*)dataDic;
                    Member * mem = [Member new];
                    
                    mem.workContractsId = [di valueForKey:@"workContactsId"];
                    mem.workGroupId = [di valueForKey:@"workGroupId"];
                    mem.isAdmin = [[di valueForKey:@"isAdmin"] boolValue];
                    mem.userId = [di valueForKey:@"userId"];
                    mem.name = [di valueForKey:@"name"];
                    mem.officeTel = [di valueForKey:@"officeTel"];
                    mem.email = [di valueForKey:@"email"];
                    mem.duty = [di valueForKey:@"duty"];
                    mem.img = [di valueForKey:@"img"];
                    mem.QQ = [di valueForKey:@"QQ"];
                    mem.createTime = [di valueForKey:@"createTime"];
                    mem.status = [[di valueForKey:@"status"] boolValue];
                    
                    return mem;
                }
            }
        }
        
    }

    return [Member new];
}

+ (NSArray*)getMembersByWorkGroupIDAndLabelID:(NSString*)workGroupId labelId:(NSString*)labelId
{
    NSMutableArray* array = [NSMutableArray array];

    NSString* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&labelId=%@",MARK_URL,workGroupId,labelId]];
    
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
                            
                            Member* mem = [Member new];
                            
                            NSLog(@"%@",[di valueForKey:@"workContactsId"]);
                            
                            mem.workContractsId = [di valueForKey:@"workContactsId"];
                            mem.workGroupId = [di valueForKey:@"workGroupId"];
                            mem.isAdmin = [[di valueForKey:@"isAdmin"] boolValue];
                            mem.userId = [di valueForKey:@"userId"];
                            mem.name = [di valueForKey:@"name"];
                            mem.officeTel = [di valueForKey:@"officeTel"];
                            mem.email = [di valueForKey:@"email"];
                            mem.duty = [di valueForKey:@"duty"];
                            mem.img = [di valueForKey:@"img"];
                            mem.QQ = [di valueForKey:@"QQ"];
                            mem.createTime = [di valueForKey:@"createTime"];
                            mem.status = [[di valueForKey:@"status"] boolValue];
                            mem.isHave = [[di valueForKey:@"have"] boolValue];
                            
                            [array addObject:mem];
                        }
                    }
                }
            }
        }
        
    }
    
    return array;
}

+ (BOOL)memberUpdateWgPeopleStrtus:(NSString*)workContactsId status:(NSString *)status
{
    BOOL isOk = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:workContactsId forKey:@"workContactsId"];
    
    [dic setObject:status forKey:@"status"];
    
    NSString* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATEWGPEOPLESTRUS_URL postData:dic];
    
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
