//
//  Group.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpBaseFile.h"
#import "CommonFile.h"
#import "LoginUser.h"
#import "Mark.h"

@interface Group : NSObject

@property (nonatomic,strong) NSString*  messageCount;
@property (nonatomic,strong) NSString*  workGroupName;
@property (nonatomic,strong) NSString*  workGroupImg;
@property (nonatomic,strong) NSString*  workGroupId;
@property (nonatomic,strong) NSString*  workGroupMain;
@property (nonatomic,assign) BOOL  isAdmin;
@property (nonatomic,strong) NSString*  userName;
@property (nonatomic,assign) BOOL isReceive;

+ (NSArray*)getGroupsByUserID:(NSString*)userID marks:(NSArray**)markArray workGroupId:(NSString *)workGroupId searchString:(NSString*)str;

+ (NSArray*)getWorkGroupListByUserID:(NSString*)userID selectArr:(NSMutableArray **)selectArr;
+ (BOOL)inviteNewUser:(NSString*)loginUserId workGroupId:(NSString*)workGroupId source:(NSInteger)source sourceValue:(NSString*)sourceStr;
+ (BOOL)createNewGroup:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img workGroupId:(NSString **)workGroupId;

+ (BOOL)updateGroup:(NSString*)wgid name:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img;
+ (NSDictionary*)groupDicByWorkGroupId:(NSString*)workGroupId isAdmin:(NSString**)admin;
+ (BOOL)updateWgSubscribeStatus:(NSString *)groupId isReceive:(BOOL) isReceive;

@end
