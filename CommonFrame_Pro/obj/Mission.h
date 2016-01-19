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
    TaskTypeShare           = 2,//异常
    TaskTypeNoitification   = 8,//申请
    TaskTypeApplication     = 4,//(没有用了）
    TaskTypeJianYi          = 3,//议题
    TaskTypePlan            = 5,//工作计划
    TaskTypeConclusion      = 6//工作总结
}TaskType;

@interface Mission : NSObject

@property (nonatomic,strong) NSString*  monthAndDay;
@property (nonatomic,strong) NSString*  hour;
@property (nonatomic,assign) BOOL       isPlanTask;
@property (nonatomic,assign) BOOL       isAccessory;
@property (nonatomic,strong) NSString*  planExecTime;
@property (nonatomic,strong) NSString*  finishTime;
@property (nonatomic,strong) NSString*  startTime;
@property (nonatomic,strong) NSString*  remindTime;
@property (nonatomic,strong) NSString*  createUserId;
@property (nonatomic,strong) NSString*  taskId;
@property (nonatomic,strong) NSString*  workGroupId;
@property (nonatomic,strong) NSString*  workGroupName;
@property (nonatomic,strong) NSString*  main;
@property (nonatomic,strong) NSString*  title;
@property (nonatomic,assign) NSInteger  type;// 1：任务  2：异常  3:议题 8:申请
@property (nonatomic,assign) NSInteger  status;//-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
@property (nonatomic,strong) NSString*  userImg;
@property (nonatomic,strong) NSString*  userName;
@property (nonatomic,assign) NSInteger  totalPages;
@property (nonatomic,strong) NSString*  liableUserId;           //责任人id
@property (nonatomic,strong) NSString*  lableUserImg;           //责任人头像url
@property (nonatomic,strong) NSString*  lableUserName;           //责任人名字
@property (nonatomic,strong) NSArray*   partList;               //参与者
@property (nonatomic,strong) NSArray*   cclist;                 //抄送者
@property (nonatomic,assign) BOOL       isLabel;                //是否使用标签
@property (nonatomic,strong) NSArray*   labelList;              //标签集合
@property (nonatomic,strong) NSArray*   accessoryList;              //标签集合
@property (nonatomic,assign) BOOL       isRead;                //是否读
@property (nonatomic, assign) BOOL      isNewCom;           //新评论
@property (nonatomic, assign) int       accessoryNum;//附件数
@property (nonatomic, assign) int       replayNum;//评论数
@property (nonatomic, assign) int       childNum;//子任务数
@property (nonatomic,strong) NSArray*   childTaskList;          //子任务集合
@property (nonatomic,strong) NSString*  createTime;//创建时间
@property (nonatomic, assign) BOOL      isInstructions;           //批示权限
@property (nonatomic, strong) NSString * parentId;

@property (nonatomic, strong) NSNumber * labelId;
@property (nonatomic, strong) NSString * reason;

@property (nonatomic, assign) NSInteger section;//工作计划添加任务该任务所在的section


+ (NSDictionary*)getMssionListbyUserID:(NSString*)userId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount workGroupId:(NSString *)wgId termString:(NSString*)termStr keyString:(NSString *)keyStr;
+ (NSMutableArray*)getMssionListbyWorkGroupID:(NSString*)groupId andUserId:(NSString *)userId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount;

+ (Mission*)detail:(NSString*)taskId commentArray:(NSArray**)comments imgArr:(NSArray **)imgArr messageId:(NSString *)messageId;

//pusblish mission
- (BOOL)sendMission:(BOOL)isMission taksId:(NSString **)taskId;
- (BOOL)sendMissionFromWorkPlan:(BOOL)isMission taksId:(NSString **)taskId;//从工作计划创建任务

+ (BOOL)reomveMission:(NSString*)taskId;
+ (Mission*)missionInfo:(NSString*)taskId responsible:(NSArray**)responsibleArray participants:(NSArray**)participantArray copyTo:(NSArray**)copyToArray labels:(NSArray**)labelArray accessories:(NSArray**)accessoryArray;

+ (NSDictionary*)missionInfo:(NSString*)taskId;

+ (BOOL)findWgPeopleTrends:(NSString*)createUserId workGroupId:(NSString *)groupId currentPageIndex:(NSInteger)page pageSize:(NSInteger)rowCount dataListArr:(NSMutableArray **)dataListArr member:(Member **)member;

+ (BOOL)sendAllMission:(BOOL)isMission taksId:(NSString **)taskId withArr:(NSArray *)missionArr;

+ (BOOL)updateTaskStatus:(NSString*)taskId status:(NSInteger )status;//3.12、更改任务状态(V1.1新增接口)POST
+ (NSArray *)findTaskList:(NSString*)taskId mainMissionDic:(NSMutableDictionary **)mainMissionDic;

+ (BOOL)createWorkPlan:(NSString*)loginUserId workGroupId:(NSString*)workGroupId workPlanTitle:(NSString *)workPlanTitle startTime:(NSString *)startTime finishTime:(NSString *)finishTime taskList:(NSArray*)taskList;//创建工作计划

+ (Mission*)findWorkPlanDetailTx:(NSString*)taskId commentArray:(NSArray**)comments finishArray:(NSArray**)finishArr unfinishArray:(NSArray **)unfinishArr;//找到工作计划详情

+ (Mission*)intoUpdateWorkPlan:(NSString*)taskId startTime:(NSString *)startTime andFinishTime:(NSString *)finishTime;//进入修改工作计划详情

+ (BOOL)updateWorkPlan:(NSString*)loginUserId taskId:(NSString *)taskId workGroupId:(NSString*)workGroupId workPlanTitle:(NSString *)workPlanTitle startTime:(NSString *)startTime finishTime:(NSString *)finishTime taskList:(NSArray*)taskList andType:(NSString *)type;//修改工作计划

@end
