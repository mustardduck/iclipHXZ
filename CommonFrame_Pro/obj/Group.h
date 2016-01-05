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

@property (nonatomic,strong) NSString*  messageCount;//消息数
@property (nonatomic,strong) NSString*  allNum;//评论数
@property (nonatomic,strong) NSString*  workGroupName;
@property (nonatomic,strong) NSString*  workGroupImg;
@property (nonatomic,strong) NSString*  workGroupId;
@property (nonatomic,strong) NSString*  workGroupMain;//slogan
@property (nonatomic,strong) NSString*  workGroupPeopleNum;//人员数
@property (nonatomic,assign) BOOL  isAdmin;
@property (nonatomic,strong) NSString*  userName;
@property (nonatomic,assign) BOOL isReceive;
@property (nonatomic,strong) UIImage * workGroupImage;

+ (NSArray*)getGroupsByUserID:(NSString*)userID marks:(NSArray**)markArray workGroupId:(NSString *)workGroupId searchString:(NSString*)str allNum:(NSString **)allNum;

+ (NSArray*)getWorkGroupListByUserID:(NSString*)userID selectArr:(NSMutableArray **)selectArr;
+ (BOOL)inviteNewUser:(NSString*)loginUserId workGroupId:(NSString*)workGroupId source:(NSInteger)source sourceValue:(NSString*)sourceStr;
+ (BOOL)inviteNewUserList:(NSString*)loginUserId workGroupId:(NSString*)workGroupId inviteArr:(NSArray*)inviteArr;

+ (BOOL)createNewGroup:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img workGroupId:(NSString **)workGroupId;

+ (BOOL)updateGroup:(NSString*)wgid name:(NSString*)workGroupName description:(NSString*)workGroupMain groupImage:(NSString*)img;
+ (NSDictionary*)groupDicByWorkGroupId:(NSString*)workGroupId isAdmin:(NSString**)admin;
+ (BOOL)updateWgSubscribeStatus:(NSString *)groupId isReceive:(BOOL) isReceive;

+ (NSArray *) findUserMainLabel:(NSString *)userId workGroupId:(NSString *) workGroupId;//找到用户的主要标签

+ (NSArray *) findUserMainLabelTask:(NSString *)userId workGroupId:(NSString *) workGroupId labelId:(NSString *)labelIdStr;//找到用户的主要标签下的任务

+ (NSArray *) findUserTaskByTime:(NSString *)userId workGroupId:(NSString *) workGroupId;//查找工作组工作管理

@end
