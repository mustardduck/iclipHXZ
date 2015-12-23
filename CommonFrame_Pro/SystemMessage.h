//
//  SystemMessage.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/22.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemMessage : NSObject

@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) NSString * createTime;
@property (nonatomic, strong) NSString * source;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * orgName;
@property (nonatomic, strong) NSString * wgName;
@property (nonatomic, strong) NSString * mobile;
@property (nonatomic, strong) NSString * createId;
@property (nonatomic, strong) NSString * sourceId;
@property (nonatomic,assign) NSInteger  totalPages;

+ (NSMutableArray*)findSysMessage:(NSString*)userID currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount;//找到消息中心系统消息

+ (BOOL)examineUserApply:(NSString*)requestId status:(NSString *)status;//审核成员加入


@end
