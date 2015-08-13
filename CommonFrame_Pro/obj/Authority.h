//
//  Authority.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/21.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Authority : NSObject

@property (nonatomic,assign) NSInteger  wgRoleId;
@property (nonatomic,strong) NSString*  remark;
@property (nonatomic,strong) NSString*  wgRoleName;
@property (nonatomic,assign) BOOL       isHave;

+ (NSArray*)getMemberRoleArrayByWorkGroupIDAndWorkContractID:(NSString*)workgroupId WorkContractID:(NSString*)contractId;
+ (BOOL)changeMemberAuthority:(NSArray*)authorityArray workContractID:(NSString*)contractId;

@end
