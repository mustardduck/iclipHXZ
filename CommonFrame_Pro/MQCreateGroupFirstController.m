//
//  MQCreateGroupFirstController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreateGroupFirstController.h"

@interface MQCreateGroupFirstController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *groupImg;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;

@property (weak, nonatomic) IBOutlet UITextField *groupTitleTxt;
@property (weak, nonatomic) IBOutlet UITextView *sloganTextView;
@property (weak, nonatomic) IBOutlet UILabel *sloganPlaceholder;

@end

@implementation MQCreateGroupFirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
