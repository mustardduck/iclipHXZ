//
//  Member.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpBaseFile.h"
#import "CommonFile.h"

@interface Member : NSObject

/*
 "orgcontactId": 5,
 "orggroupId": 1,
 "orgId": 1015050511520001,
 "userId": 1015052716120001,
 "name": "代德建",
 "company": "对双方都",
 "address": "电视访谈热敷",
 "mobile": "18375707138",
 "officeTel": "02362909365",
 "faxTel": "02362909365",
 "email": "258696109@qq.com",
 "duty": "4",
 "remark": "445",
 "img": "../static/images/default_head.png",
 "QQ": "6545455",
 "version": "1",
 "createTime": "Jul 3, 2015 8:19:38 PM",
 "status": 1,
 */

@property (nonatomic,strong) NSString*  orgcontactId;
@property (nonatomic,strong) NSString*  orggroupId;
@property (nonatomic,strong) NSString*  orgId;
@property (nonatomic,strong) NSString*  userId;
@property (nonatomic,strong) NSString*  name;
@property (nonatomic,strong) NSString*  company;
@property (nonatomic,strong) NSString*  address;
@property (nonatomic,strong) NSString*  mobile;
@property (nonatomic,strong) NSString*  officeTel;
@property (nonatomic,strong) NSString*  faxTel;
@property (nonatomic,strong) NSString*  email;
@property (nonatomic,strong) NSString*  duty;
@property (nonatomic,strong) NSString*  remark;
@property (nonatomic,strong) NSString*  img;
@property (nonatomic,strong) NSString*  QQ;
@property (nonatomic,strong) NSString*  version;
@property (nonatomic,strong) NSString*  createTime;
@property (nonatomic,assign) BOOL       status;

@property (nonatomic,strong) NSString*  workContractsId;
@property (nonatomic,strong) NSString*  workGroupId;
@property (nonatomic,assign) BOOL       isAdmin;

@property (nonatomic,assign) BOOL       isHave;
@property (nonatomic,assign) BOOL       isLeader;//是否管理者  1:是  0：不是

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSNumber * recordId;//手机通讯录ID
@property (nonatomic, strong) NSString * source;//来源   0：单位通讯录   1：电话   2：微信
@property (nonatomic, strong) NSString * sourceId;//来源的唯一Id  0：为用户Id，1为手机号码

+ (NSArray*)getAllMembers:(NSMutableArray**)sections searchText:(NSString*)searchString;
+ (NSArray*)getAllMembersExceptMeByWorkGroupID:(NSMutableArray**)sections workGroupID:(NSString*)workGroupId totalMemeberCount:(NSNumber **)totalCount;
+ (NSArray*)getAllMembersExceptMe:(NSMutableArray**)sections searchText:(NSString*)searchString workGroupId:(NSString *)groupId;
+ (NSArray*)getAllMembers:(NSMutableArray**)sections participantsArray:(NSArray*)pArray;
//+ (NSArray*)getAllMembersByWorkGroupID:(NSMutableArray**)sections workGroupID:(NSString*)workGroupId;

+ (NSArray*)getAllMembersByWorkGroupID:(NSMutableArray**)sections workGroupID:(NSString*)workGroupId totalMemeberCount:(NSNumber **)totalCount leaderArray:(NSArray **)leaderArr adminUser:(Member **)member;

+ (Member*)getMemberInfoByWorkContractsID:(NSString*)contractID;
+ (NSArray*)getMembersByWorkGroupIDAndLabelID:(NSString*)workGroupId labelId:(NSString*)labelId;
+ (BOOL)memberUpdateWgPeopleStrtus:(NSString*)workContactsId status:(NSString *)status;
+ (NSArray*)getAllMembersExceptMeAndMarkExistMember:(NSMutableArray**)sections searchText:(NSString*)searchString workGroupId:(NSString *)groupId;

@end
