//
//  PreviewViewController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/9/28.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRPageControl.h"
#import "XLCycleScrollView.h"

@interface PreviewViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, assign) BOOL isShowLogo;
@property (nonatomic, strong) id icWorkingVC;

@end
