//
//  Member.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "Member.h"
#import "LoginUser.h"

#define CURL                @"/org/findOrgContactByInitial.hz"
#define WORKGROUP_URL       @"/workgroup/findWgPeopleListByInitial.hz"
#define MEMBER_INFO_URL     @"/workgroup/findWgPeopleDetail.hz"
#define MARK_URL            @"/workgroup/findWgPeopleListByLabel.hz"
#define UPDATEWGPEOPLESTRUS_URL   @"/workgroup/updateWgPeopleStrtus.hz"
#define INVITE_URL          @"/org/findOrgContactByWork.hz"

@implementation Member

+ (NSArray*)getAllMembers:(NSMutableArray**)sections searchText:(NSString*)searchString
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    NSString * urlstr = [NSString stringWithFormat:@"%@?orgId=%@", CURL, [LoginUser loginUserOrgID]];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:(searchString == nil ? urlstr : [NSString stringWithFormat:@"%@&str=%@",urlstr,searchString])];
    
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
                                        cm.mobile = [di valueForKey:@"mobile"];
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

+ (NSArray*)getAllMembersExceptMeAndMarkExistMember:(NSMutableArray**)sections searchText:(NSString*)searchString workGroupId:(NSString *)groupId
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    NSString * urlstr = [NSString stringWithFormat:@"%@?orgId=%@", INVITE_URL, [LoginUser loginUserOrgID]];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:(searchString == nil ? [NSString stringWithFormat:@"%@&workGroupId=%@",urlstr, groupId] : [NSString stringWithFormat:@"%@&workGroupId=%@&str=%@",urlstr, groupId,searchString])];
    
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
                                        cm.isHave = [[di valueForKey:@"isHave"] boolValue];
                                        
                                        [sectionMemberArray addObject:cm];
                                    }
                                }
                                if(sectionMemberArray.count)
                                {
                                    [array addObject:sectionMemberArray];
                                    
                                    [sectionArray addObject:tmpKey];
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

+ (NSArray*)getAllMembersExceptMe:(NSMutableArray**)sections searchText:(NSString*)searchString workGroupId:(NSString *)groupId
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    NSString * urlstr = [NSString stringWithFormat:@"%@?orgId=%@", INVITE_URL, [LoginUser loginUserOrgID]];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:(searchString == nil ? [NSString stringWithFormat:@"%@&workGroupId=%@",urlstr, groupId] : [NSString stringWithFormat:@"%@&workGroupId=%@&str=%@",urlstr, groupId,searchString])];
    
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
                                        cm.isHave = [[di valueForKey:@"isHave"] boolValue];

                                        if(!cm.isHave)
                                        {
                                            [sectionMemberArray addObject:cm];
                                        }
                                    }
                                }
                                if(sectionMemberArray.count)
                                {
                                    [array addObject:sectionMemberArray];
                                    
                                    [sectionArray addObject:tmpKey];
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
    
    NSString * urlstr = [NSString stringWithFormat:@"%@?orgId=%@", CURL, [LoginUser loginUserOrgID]];
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:urlstr];
    
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

+ (NSArray*)getAllMembersExceptMeByWorkGroupID:(NSMutableArray**)sections workGroupID:(NSString*)workGroupId totalMemeberCount:(NSNumber **)totalCount
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSInteger totalMCount = 0;
    
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@",WORKGROUP_URL,workGroupId]];
    
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
                                        mem.mobile = [di valueForKey:@"mobile"];
                                        mem.duty = [di valueForKey:@"duty"];
                                        mem.img = [di valueForKey:@"img"];
                                        mem.QQ = [di valueForKey:@"QQ"];
                                        mem.createTime = [di valueForKey:@"createTime"];
                                        mem.status = [[di valueForKey:@"status"] boolValue];
                                        
                                        if(mem.userId == [LoginUser loginUserID])
                                        {
                                            NSLog(@"%@", mem.userId);
                                            
                                            if(dArr.count == 1)
                                            {
                                                [sectionArray removeLastObject];
                                            }
                                        }
                                        else
                                        {
                                            [sectionMemberArray addObject:mem];
                                            
                                            totalMCount ++;
                                        }

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
    *totalCount = [NSNumber numberWithInteger:totalMCount];
    
    return array;
}

+ (NSArray*)getAllMembersByWorkGroupID:(NSMutableArray**)sections workGroupID:(NSString*)workGroupId totalMemeberCount:(NSNumber **)totalCount
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSInteger totalMCount = 0;
    
    NSArray*    tmpSection = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@",WORKGROUP_URL,workGroupId]];
    
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
                                        mem.mobile = [di valueForKey:@"mobile"];
                                        mem.duty = [di valueForKey:@"duty"];
                                        mem.img = [di valueForKey:@"img"];
                                        mem.QQ = [di valueForKey:@"QQ"];
                                        mem.createTime = [di valueForKey:@"createTime"];
                                        mem.status = [[di valueForKey:@"status"] boolValue];
                                        
                                        [sectionMemberArray addObject:mem];
                                        
                                        totalMCount ++;
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
    *totalCount = [NSNumber numberWithInteger:totalMCount];
    
    return array;
}

+ (Member*)getMemberInfoByWorkContractsID:(NSString*)contractID
{
    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workContactsId=%@",MEMBER_INFO_URL,contractID]];
    
    if (responseString == nil) {
        return [Member new];
    }
    id val = [CommonFile jsonNSDATA:responseString];
    
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

    NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?workGroupId=%@&labelId=%@",MARK_URL,workGroupId,labelId]];
    
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
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATEWGPEOPLESTRUS_URL postData:dic];
    
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
