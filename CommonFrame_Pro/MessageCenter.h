//
//  MessageCenter.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/23.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageCenter : NSObject
@property (nonatomic, strong) NSString * megId;//id
@property (nonatomic, strong) NSString * taskId; //任务Id
@property (nonatomic, strong) NSString * commentText;//评论内容
@property (nonatomic, strong) NSString * createTime;//创建时间
@property (nonatomic, strong) NSString * source;//来源  7：评论
@property (nonatomic, assign) BOOL isAccessory;//是否有附件
@property (nonatomic, strong) NSString * userName;//评论者名字
@property (nonatomic, strong) NSString * userImg;//评论者头像
@property (nonatomic, strong) NSString * missionText;//任务内容
@property (nonatomic, strong) NSString * rightImg;//右边图片
@property (nonatomic, strong) NSString * wgName;//群组名
@property (nonatomic,assign) NSInteger  totalPages;

+ (NSMutableArray*)getMessageListByUserID:(NSString*)userID currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount workGroupId:(NSString *)workGroupId;

//找到消息中心评论消息
+ (NSMutableArray*)findMessageCenterByMessage:(NSString*)userID currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount keyString:(NSString *)keyString;

 
+ (BOOL)findCommentMessageNum:(NSString *)userId commentNum:(NSString **)commentNum sysNum:(NSString **)sysNum allNum:(NSString **)allNum;

@end
