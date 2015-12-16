//
//  Organization.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/14.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpBaseFile.h"
#import "CommonFile.h"

@interface Organization : NSObject

@property (nonatomic,strong) NSString*  logo;
@property (nonatomic,strong) NSString*  name;//组织名称
@property (nonatomic,strong) NSString*  orgId;
@property (nonatomic,strong) NSString*  createName;
@property (nonatomic,strong) NSString*  createUserId;
@property (nonatomic,strong) NSString*  status; // 状态  -2：审核不过  -1：已忽略(暂无）  0:待审核  1:审核通过   

+ (NSArray*)findOrgbyStr:(NSString*)userID str:(NSString *)str;//查找单位
+ (BOOL)addOrgUser:(NSString*)userID orgId:(NSString *)orgId;//申请加入单位
+ (BOOL)addOrg:(NSString*)userID orgName:(NSString *)orgName;//创建单位

+ (NSArray*)fineExamOrg:(NSString*)userID;//找到自己的待审核列表

@end
