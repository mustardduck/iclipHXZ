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
@property (nonatomic,assign) BOOL       isSystem;
@property (nonatomic,assign) NSInteger section;
@property (nonatomic,assign) NSInteger row;

+ (NSArray*)getMarkListByWorkGroupID:(NSString*)workGroupId loginUserID:(NSString*)userid andUrl:(NSString *)url;
+ (BOOL)createNewMark:(NSString*)labelName workGroupID:(NSString*)workGroupId;
+ (BOOL)remove:(NSString*)labelID  workGroupId:(NSString*)wgid;
+ (BOOL)update:(NSString*)labelID labelName:(NSString*)name;
+ (BOOL)updateMarkMember:(NSString*)labelID workGroupID:(NSString*)workGroupId memberIdArray:(NSArray*)memberIDArray;
+ (BOOL)addWgLabelList:(NSArray*)labelNameList workGroupID:(NSString*)workGroupId;

@end
