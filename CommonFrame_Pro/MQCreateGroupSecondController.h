//
//  MQCreateGroupSecondController.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "ZLPeoplePickerViewController.h"

@interface MQCreateGroupSecondController : UIViewController

@property (nonatomic, strong) Group * workGroup;
@property (nonatomic, strong) id icCreateGroupFirstController;

@property (nonatomic, strong) NSMutableArray * inviteArr;
@property (nonatomic, strong) ZLPeoplePickerViewController *peoplePicker;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;


@end
