//
//  ICPersonalInfoViewController.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/2.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICFileViewController.h"

@interface ICPersonalInfoViewController : UIViewController <UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong) NSArray* cAccessoryArray;

@end
