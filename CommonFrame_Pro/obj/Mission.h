//
//  Mission.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/15.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpBaseFile.h"
#import "CommonFile.h"
#import "Accessory.h"
#import "PrintObject.h"
#import "NSStringEx.h"
#import "Comment.h"
#import "LoginUser.h"
#import "Member.h"
#import "Mark.h"

typedef enum {
    TaskTypeMission         = 1,//任务
    TaskTypeShare           = 2,//问题
    TaskTypeNoitification   = 3,//其他
    TaskTypeApplication     = 4,//(没有用了）
    TaskTypeJianYi          = 8//建议
}TaskType;

@interface Mission : NSObject

@property (nonatomic,strong) NSString*  monthAndDay;
@property (nonatomic,strong) NSString*  hour;
@property (nonatomic,assign) BOOL       isPlanTask;
@property (nonatomic,assign) BOOL       isAccessory;
@property (nonatomic,strong) NSString*  planExecTime;
@property (nonatomic,strong) NSString*  finishTime;
@property (nonatomic,strong) NSString*  remindTime;
@property (nonatomic,strong) NSString*  createUserId;
@property (nonatomic,strong) NSString*  taskId;
@property (nonatomic,strong) NSString*  workGroupId;
@property (nonatomic,strong) NSString*  workGroupName;
@property (nonatomic,strong) NSString*  main;
@property (nonatomic,strong) NSString*  title;
@property (nonatomic,assign) NSInteger  type;//
@property (nonatomic,assign) NSInteger  status;
@property (nonatomic,strong) NSString*  userImg;
@property (nonatomic,strong) NSString*  userName;
@property (nonatomic,assign) NSInteger  totalPages;
@property (nonatomic,assign) NSString*  liableUserId;           //责任人
@property (nonatomic,strong) NSArray*   partList;               //参与者
@property (nonatomic,strong) NSArray*   cclist;                 //抄送者
@property (nonatomic,assign) BOOL       isLabel;                //是否使用标签
@property (nonatomic,strong) NSArray*   labelList;              //标签集合
@property (nonatomic,strong) NSArray*   accessoryList;              //标签集合
@property (nonatomic,assign) BOOL       isRead;                //是否读
@property (nonatomic, assign) BOOL      isNewCom;           //新评论
@property (nonatomic, assign) int       accessoryNum;//附件数
@property (nonatomic, assign) int       replayNum;//评论数

+ (NSDictionary*)getMssionListbyUserID:(NSString*)userId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount workGroupId:(NSString*)wgId termString:(NSString*)termStr;
+ (NSMutableArray*)getMssionListbyWorkGroupID:(NSString*)groupId andUserId:(NSString *)userId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount;

+ (Mission*)detail:(NSString*)taskId commentArray:(NSArray**)comments imgArr:(NSArray **)imgArr messageId:(NSString *)messageId;

//pusblish mission
- (BOOL)sendMission:(BOOL)isMission taksId:(NSString **)taskId;

+ (BOOL)reomveMission:(NSString*)taskId;
+ (Mission*)missionInfo:(NSString*)taskId responsible:(NSArray**)responsibleArray participants:(NSArray**)participantArray copyTo:(NSArray**)copyToArray labels:(NSArray**)labelArray accessories:(NSArray**)accessoryArray;

+ (BOOL)findWgPeopleTrends:(NSString*)createUserId workGroupId:(NSString *)groupId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount dataListArr:(NSMutableArray **)dataListArr member:(Member **)member;

+ (BOOL)sendAllMission:(BOOL)isMission taksId:(NSString **)taskId withArr:(NSArray *)missionArr;

@end
