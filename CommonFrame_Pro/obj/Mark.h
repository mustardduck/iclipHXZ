//
//  Mark.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpBaseFile.h"
#import "CommonFile.h"

#define CURL                @"/workgroup/findWgLabel.hz"
#define ME_LABEL_CURL       @"/workgroup/findWgMeLabel.hz"

@interface Mark : NSObject

@property (nonatomic,strong) NSString*  labelId;
@property (nonatomic,strong) NSString*  labelName;
@property (nonatomic,strong) NSString*  labelImage;
@property (nonatomic,assign) BOOL       isSystem;//等级  1系统标签  2 自定义标签
@property (nonatomic,assign) NSInteger section;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic, assign) BOOL mainLabel;// 是否主要工作  1：是  0不是

@property (nonatomic,strong) NSString*  createName;//创建者名字
@property (nonatomic,strong) NSString*  labelNum;//标签使用次数
@property (nonatomic,assign) BOOL isHave;//是否具有该标签   1：具有   0：不具有

+ (NSArray*)getMarkListByWorkGroupID:(NSString*)workGroupId loginUserID:(NSString*)userid andUrl:(NSString *)url;
+ (BOOL)createNewMark:(NSString*)labelName workGroupID:(NSString*)workGroupId;
+ (BOOL)remove:(NSString*)labelID  workGroupId:(NSString*)wgid;
+ (BOOL)update:(NSString*)labelID labelName:(NSString*)name;
+ (BOOL)updateMarkMember:(NSString*)labelID workGroupID:(NSString*)workGroupId memberIdArray:(NSArray*)memberIDArray;
+ (BOOL)addWgLabelList:(NSArray*)labelNameList workGroupID:(NSString*)workGroupId;

+ (NSArray*)getMarkListByWorkGroupID:(NSString*)workGroupId loginUserID:(NSString*)userid andUrl:(NSString *)url selectArr:(NSMutableArray **)selectArr;

+ (BOOL)updateLabelMainWork:(NSString *)labelId isMainLabel:(BOOL) isMainLabel;

+ (NSArray *) findWgLabelForUpdate:(NSString *)workGroupId workContactsId:(NSString *) workContactsId;//

+ (BOOL) updateWgPeopleLabelNew:(NSString *)tagStr workContactsId:(NSString *)workContactsId;

@end
