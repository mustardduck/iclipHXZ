//
//  ICWorkingDetailViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YFInputBar.h"
#import "UIColor+HexString.h"
#import "Mission.h"
#import "LoginUser.h"
#import "Comment.h"
#import <ImageIO/ImageIO.h>
#import "ICPublishSharedAndNotifyViewController.h"
#import "ICPublishMissionViewController.h"

@interface ICWorkingDetailViewController : UIViewController

@property (nonatomic,strong) NSString* taskId;
@property (nonatomic,strong) NSString* commentsId;
@property (nonatomic,strong) NSMutableArray*             replyList;
@property (nonatomic,assign) NSInteger                   indexRow;

@property (nonatomic,assign) NSInteger              indexInMainArray;
@property (nonatomic,strong) id                     icMainViewController;
@property (nonatomic,strong) NSString*              content;

@property (nonatomic,strong) IBOutlet UITableView*       tableView;

@property (nonatomic,strong) NSString*              workGroupId;
@property (nonatomic,assign) BOOL              isFromAllGroup;

@property (nonatomic,strong) NSString*              messageId;

@property (nonatomic,strong) NSArray*              commentsArr;
@property (nonatomic,strong) NSArray*              imageArr;


@end
