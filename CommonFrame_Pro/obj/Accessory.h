//
//  Accessory.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HttpBaseFile.h"

@interface Accessory : NSObject

@property (nonatomic,strong) NSString*  name;
@property (nonatomic,strong) NSString*  address;
@property (nonatomic,assign) BOOL       isComplete;
@property (nonatomic,assign) NSInteger  source;
@property (nonatomic,assign) NSInteger  breakpointSize;
@property (nonatomic,assign) BOOL       status;
@property (nonatomic,strong) NSString*  accessoryId;
@property (nonatomic,assign) NSInteger  type;
@property (nonatomic,strong) NSString*  size;
@property (nonatomic,strong) NSString*  sourceId;
@property (nonatomic,strong) NSString*  addTime;
@property (nonatomic,strong) NSString*  jsonStr;
@property (nonatomic,strong) NSString*  userName;
@property (nonatomic,strong) NSString*  userImg;
@property (nonatomic,strong) NSString* fileType;// 1: doc/docx  2: xls/xlsx 3: ppt/pptx 4: pdf 5: png/jpg 6:其他
@property (nonatomic, strong) NSString * allUrl;//查看原图
@property (nonatomic, strong) NSString * originImageSize;//文件大小
@property (nonatomic, strong) NSString * originFileName;//文件名字

+(Accessory*)jsonToObj:(NSString*)jsonString;

+ (NSArray*)getAccessoryListByWorkGroupID:(NSString*)workGroupId;

@end
