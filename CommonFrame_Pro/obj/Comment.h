//
//  Comment.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/22.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

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

@property(nonatomic,strong) NSString*   taskId;
@property(nonatomic,strong) NSString*   parentId;
@property(nonatomic,strong) NSString*   parentName;
@property(nonatomic,strong) NSString*   createTime;
@property(nonatomic,assign) NSInteger   praiseNum;
@property(nonatomic,assign) BOOL        isPraised;
@property(nonatomic,assign) NSInteger   level;//1批示 2评论 
@property(nonatomic,strong) NSString*   hourStr;
@property(nonatomic,strong) NSString*   userId;
@property(nonatomic,strong) NSString*   userName;
@property(nonatomic,strong) NSString*   commentsId;
@property(nonatomic,strong) NSString*   userImg;
@property(nonatomic,strong) NSString*   main;
@property(nonatomic,strong) NSArray*    comments;
@property(nonatomic,assign) BOOL        hasChild;
@property(nonatomic, strong) NSArray * accessoryList;

- (BOOL)sendComment;
- (BOOL)sendComment:(NSString**)commentId;
+ (BOOL)praise:(NSString*)commentId workGroupId:(NSString*)wgid hasPraised:(BOOL)isPraise;
- (BOOL)deleteTaskComment:(NSString *) commentsId taskId:(NSString *) taskId;
- (BOOL)createCommentAccessory:(NSMutableDictionary *)commAccDic;
- (BOOL)createCommentAccessoryId:(NSMutableDictionary **)commDic;
@end
