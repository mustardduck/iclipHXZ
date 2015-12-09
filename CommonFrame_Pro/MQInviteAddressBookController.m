//
//  MQInviteAddressBookController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/9.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQInviteAddressBookController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ZCAddressBook.h"
#import "UICommon.h"
#import "SVProgressHUD.h"

@interface MQInviteAddressBookController ()<ABPeoplePickerNavigationControllerDelegate>

@end

@implementation MQInviteAddressBookController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableDictionary*dic;
    NSArray*array;
    //获得Vcard
    dic= [[ZCAddressBook shareControl]getPersonInfo];
    //获得序列索引
    array=[[ZCAddressBook shareControl]sortMethod];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
